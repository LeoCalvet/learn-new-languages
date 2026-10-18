# Level Up — Ruby & Rails, no hand-holding

## The deal

You write the code. I do **not** guide you, give hints, or write solutions.
When you finish a problem or a Rails project, show me your code and I will
**review** it: I tell you if the way you did it was good, what I would change,
and why. Think of me as a senior who only does code review.

This folder exists because your `ERP-iuupi` code already shows you handle
service objects, `ActiveSupport::Concern`, `CurrentAttributes`, polymorphic
associations, enums, a custom `notifiable` DSL, the reflection API and
event-sourced change-sets. That is solid middle-to-upper-middle Rails. To reach
the next level you need the **pure-Ruby** muscles that Rails hides from you:
metaprogramming, `Enumerable`/`Enumerator` internals, Fibers/laziness,
frozen-string semantics, exact money math, and writing a parser/interpreter
from scratch.

## Ruby problems (10)

Each `.rb` file in this folder is one problem. Every file is self-contained and
runs with plain Ruby — **no Rails, no gems**:

```
ruby 01_price_basket.rb
```

Structure of every file:

1. A header: difficulty + what you must build/fix.
2. **Broken / incomplete** code. It has real bugs — your job is to fix them.
3. A `# ---- DO NOT EDIT BELOW THIS LINE ----` self-check: assertions that
   define the exact expected behavior. They **fail right now**. Make them pass.

Rules:

- Do **not** edit anything below the "DO NOT EDIT" marker.
- Do **not** ask me for the solution. I won't give it. I only review your fix.
- Run the file; when it prints `NN OK ✓` you are done — then show me for review.
- Most problems have **several** correct fixes. I will judge which one you chose.

Difficulty (calibrated to your real code, so "easy" here is **not** trivial):

| #   | Difficulty | File                        | What it trains                                            |
|-----|------------|-----------------------------|-----------------------------------------------------------|
| 01  | easy       | `01_price_basket.rb`        | frozen strings, BigDecimal vs Float money, promo math    |
| 02  | easy       | `02_availability_grid.rb`   | wrap-around indexing, inverted boolean logic, thresholds  |
| 03  | middle     | `03_pipeline.rb`            | `Enumerator::Lazy`, block arity, composable pipelines     |
| 04  | middle     | `04_custom_enumerable.rb`    | `Enumerable` mixin, `each` contract (`enum_for`), lists   |
| 05  | middle     | `05_cache_with_ttl.rb`      | TTL/time logic, injected clock, defensive copy, locking   |
| 06  | middle     | `06_method_missing_proxy.rb`| `method_missing`, `respond_to_missing?`, `&block`, `super`|
| 07  | middle     | `07_state_machine.rb`       | DSL via metaprogramming (`define_method`, `instance_eval`)|
| 08  | hard       | `08_template_engine.rb`     | tokenizer/parser, recursive rendering, nested blocks      |
| 09  | hard       | `09_lazy_streams.rb`        | lazy infinite streams, memoization, stream-merge algorithm|
| 10  | hard       | `10_interpreter.rb`         | recursive-descent parser, environments/scopes, closures  |

Do them in order. Resist skipping to the hard ones — the middle ones teach
patterns the hard ones assume you already own.

## Rails projects (3)

See `RAILS_PROJECT_IDEAS.md`. Each is a full app you build **solo**. Each spec
lists the exact "middle → hard Rails logic" I will grade you on. Build it, then
ask me to review.

The three projects deliberately extend things your ERP already does (services,
jobs, state machines, `CurrentAttributes`) into territory it does **not** cover:
money/proration, concurrent-write protection (advisory locks), and SQL range
queries for double-booking.
