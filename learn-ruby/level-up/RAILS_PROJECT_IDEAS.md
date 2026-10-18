# Rails Project Ideas — build them solo, I only review

Three full Rails apps. Build each one yourself, end to end. I will **not** guide
you or write code. When you hand me a project (or a slice of one), I review it
against the "What I will grade you on" list for that project and tell you what
is good, what is weak, and what I would change.

Use your real stack from `ERP-iuupi`: **Rails 8, PostgreSQL, Solid Queue, Solid
Cable, action_policy, Devise, Pagy, Inertia + Vite**. Match the patterns you
already use (service objects, query objects, `CurrentAttributes`, concerns,
enums, RSpec + factory_bot). The point is to extend muscles you already have
into territory your ERP does **not** cover: money/proration, concurrent-write
protection, and SQL range queries.

Rules:

- No AI-generated solutions while building. Struggle, read the Rails/PG docs,
  come to me for **review only**.
- Each project lists acceptance criteria that are precise enough for me to
  verify by reading your code and running your test suite.
- Write tests (RSpec). I grade the tests too — a passing suite that does not
  actually exercise the edge cases below is a weak submission.
- Money is **always** integers-cents or `BigDecimal`, never `Float`. I will
  reject any `Float` currency math on sight.

Difficulty is ordered: do them in sequence.

---

## Project 1 — Multi-tenant SaaS billing engine

A subscription billing system for a multi-tenant SaaS. Tenants subscribe to
plans, get invoiced on a cycle, can change plans mid-cycle, and can have
usage-based metering on top of a flat fee.

### Data model (sketch — you design it)

- `Tenant` (account), `User` (Devise), `Plan` (name, base_price_cents,
  interval: monthly/yearly, trial_days).
- `Subscription` (tenant_id, plan_id, status enum: trialing/active/past_due/
  canceled, current_period_start, current_period_end, canceled_at,
  trial_ends_at, lock_version).
- `UsageEvent` (tenant_id, metric, units, recorded_at) — metering.
- `Invoice` (tenant_id, number, status enum: draft/open/paid/void,
  total_cents, issued_at, paid_at, idempotency_key UNIQUE).
- `InvoiceLine` (invoice_id, kind: subscription/usage/proration/credit,
  description, amount_cents).

### What I will grade you on

1. **Proration (the core).** A tenant upgrades from Pro (R$100/mo) to Elite
   (R$300/mo) on day 15 of a 30-day cycle. You must credit the unused 15 days of
   Pro (R$50) and charge 15 days of Elite prorated (R$150), netting +R$100 on
   the next invoice. Downgrade is the mirror. I will check the exact cents
   math, the rounding policy you chose (and that you applied it consistently),
   and that you used `BigDecimal`/integer cents, never `Float`.

2. **Subscription state machine** with time-based transitions: `trialing →
   active` at `trial_ends_at`; `active → past_due` when an invoice is unpaid
   past a grace period; `past_due → canceled` after N days. Driven by a Solid
   Queue job, not a cron guess. Must be idempotent: re-running the job for the
   same subscription at the same time must not double-fire callbacks or emit
   duplicate invoices.

3. **Idempotency.** Invoices carry a unique `idempotency_key`. The invoicing
   job and any webhook handler must be safe to retry: processing the same
   event/invoice twice produces one invoice, not two. I will look for a unique
   constraint plus `ON CONFLICT`/rescue-and-reuse, not a "check then insert"
   race.

4. **Usage metering.** A `UsageEvent` stream per tenant per metric per billing
   period; the invoice totals usage within `[current_period_start,
   current_period_end]` and prices it (e.g., tiered: first 1000 units free,
   next 9000 at R$0.01/unit, above at R$0.005/unit). Counter must reset per
   period and handle events arriving out of order.

5. **Per-tenant sequential invoice numbers.** Invoice `number` is sequential
   per tenant (TEN-0001, TEN-0002…) with no gaps and no duplicates under
   concurrent invoicing of the same tenant. I will look for a row-level or
   advisory lock, not `MAX(number)+1`.

6. **Money correctness in the view/serializer.** Whatever you render (Inertia
   props or JSON) must round for display at the boundary only, never rounding
   the stored cents.

### Anti-patterns I will flag

`Float` anywhere in money; `MAX(number)+1` without a lock; "check if exists
then insert" for idempotency; callbacks that fire twice on retry; proration
that rounds per-line then sums (round once at the end).

---

## Project 2 — Real-time auction marketplace

A live auction platform. Auctions schedule, go live, accept bids over
ActionCable, auto-extend on late bids, and settle to a sale when they close.

### Data model (sketch)

- `Auction` (item_id, status enum: scheduled/live/closing/closed, start_at,
  end_at, reserve_price_cents, high_bid_id, lock_version).
- `Bid` (auction_id, bidder_id, amount_cents, created_at).
- `Sale` (auction_id, winner_id, amount_cents, status) — created on close.

### What I will grade you on

1. **Concurrent-bid race protection.** Two users bid R$101 at the same
   millisecond on the same auction. Exactly one becomes the new high bid; the
   other must be rejected or refreshed, never both stored as "high". I will
   look for optimistic locking (`lock_version` +
   `ActiveRecord::StaleObjectError` rescue and retry) **or** a Postgres
   advisory lock keyed per auction. No "read high_bid then write" without a
   lock.

2. **Time-based state machine + job scheduling.** `scheduled -> live` at
   `start_at` and `live -> closed` at `end_at` are driven by Solid Queue
   **scheduled** jobs, not a polling loop. When the closing job runs it must
   check the auction is still `live` and `end_at` has not been pushed back (a
   late bid can reschedule it -- see #3); if it was rescheduled, the job must
   no-op and a new scheduled job must exist. Idempotent on retry.

3. **Auto-extend (popcorn bidding).** A bid placed within the last 60 seconds
   extends `end_at` by 60 seconds (capped). Extending must reschedule the
   closing job atomically with the bid. I will check the bid transaction, the
   new `end_at`, and that the previously-scheduled closing job is superseded
   (not left to fire early).

4. **Reserve price.** Reserve is hidden. On close, a sale is created only if
   the high bid >= reserve; otherwise the auction closes as "no sale". Bidders
   must not learn the reserve from the UI or the cable stream. I will check
   the serializer/policy and the cable payload.

5. **ActionCable correctness.** An `AuctionChannel` per auction; on subscribe
   it streams the **current** state (high bid amount, time left, status) so a
   reconnect/cold start is correct. On a new bid it broadcasts the new high
   amount and time left but **not** the bidder's identity. Broadcasts must be
   scoped to that auction's stream only -- no cross-auction leakage.

6. **Stale-bid rejection.** A bid <= current high bid (or below the min
   increment) is rejected with a clear validation error surfaced to the
   channel; it must not persist and must not broadcast. Race: a bid that was
   valid when the user clicked but is now stale because of #1 must be rejected,
   not silently dropped.

### Anti-patterns I will flag

Read-modify-write on `high_bid_id` without a lock; broadcasting bidder
identities; relying on `Time.now` instead of `Time.current`/db time for
`end_at` comparisons; a closing job that does not re-check `end_at`;
client-trusted bid amounts.


---

## Project 3 — Inventory & reservation system with availability search

A booking system for finite-capacity resources (e.g., equipment bays, rooms).
Users search availability across a date range and reserve; reservations can be
held tentatively then confirmed, with automatic expiry.

### Data model (sketch)

- `Resource` (name, capacity).
- `Reservation` (resource_id, tenant_id, starts_at, ends_at, status enum:
  held/confirmed/canceled, quantity, held_until, lock_version).
- A range type or two timestamp columns for `[starts_at, ends_at)`.

### What I will grade you on

1. **Overlap detection in SQL (the core).** Two reservations for the same
   resource must not overlap. Adjacent reservations (one ends at 10:00, the
   next starts at 10:00) are allowed. I will look for a PostgreSQL
   `EXCLUDE USING gist (resource_id WITH =, tsrange WITH &&)` constraint (with
   `btree_gist` for the integer `resource_id`), **or** a correct scoped overlap
   query inside a transaction with a lock. The boundary `[start, end)` must be
   half-open exactly -- an off-by-one at the boundary is the most common bug
   here and I will hunt for it.

2. **Availability search.** Given a `[start, end)` and a `quantity`, return
   resources that have at least `quantity` free capacity for **every moment**
   in the range. Capacity is `resource.capacity - sum(quantity of overlapping
   confirmed reservations)`. The trap: a resource with capacity 5 that has one
   reservation of 3 overlapping part of the range and another of 4 overlapping
   a different part is NOT available for 3 across the whole range. You must
   compute per-slice (the peak overlapping demand), not a single `SUM` across
   the whole range. I will give you a fixture that exposes a naive
   `SUM`-over-whole-range implementation as wrong.

3. **Double-booking prevention with holds.** A reservation starts as `held`
   with a `held_until` (TTL). Creating a hold must take an advisory lock on the
   resource (or rely on the EXCLUDE constraint) so two simultaneous holds for
   the last unit cannot both succeed. A Solid Queue job expires (`held ->
   canceled`) holds past `held_until`; confirming turns `held -> confirmed`.
   I will check the lock scope, the transaction boundaries, and that the
   EXCLUDE constraint treats `held` and `confirmed` reservations equally as
   capacity-consuming.

4. **Time-zone correctness.** Users book in their tz; `starts_at`/`ends_at`
   are stored in UTC (`timestamptz`). The overlap query and the day boundaries
   for "nights" must use the user's tz, not server tz. A reservation that
   crosses a DST change must not gain/lose an hour. I will check you used
   `Time.use_zone` / `in_time_zone` at the boundaries and that the range
   comparison is on absolute instants.

5. **Partial-availability / split bookings (stretch).** If no single resource
   has enough capacity for the whole range, optionally suggest a split across
   resources or sub-ranges. This is hard: a correct greedy/dynamic solution is
   a bonus, a wrong one is worse than none -- I will check you did not claim
   availability you cannot honor.

6. **Authorization.** `action_policy` policies so a tenant can only
   read/cancel their own reservations and only sees their own in availability
   overlap queries (a `current_tenant` scope, like your ERP's `Current`).

### Anti-patterns I will flag

`SUM` over the whole range to compute capacity (ignores per-slice peaks);
half-open range implemented as `start < other.end AND end > other.start` with
the wrong `<`/`<=`; comparing `Date` to `Time`; holds without a lock;
`Time.now` for `held_until` expiry comparisons.

---

## How to use this file

Pick one project. Read its grading list first -- those are the hard parts; let
them drive your schema and your test suite. Write failing RSpec examples for
each bullet before you implement. When a slice is green, hand it to me for
review with the relevant tests. I will tell you what is good, what is fragile,
and what I would change. Then move to the next bullet. Do not ask me to write
the code -- that is your job now.

