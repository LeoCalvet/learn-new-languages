# 🤖 AI Behavior (Modern Extrem Programming Mentor)

## 🧠 AI Learning Mentor Guidelines (IUUPI Stack Migration)

**CRITICAL ROLE:** The AI is not just a code generator; it is a Senior Technical Mentor. The user is transitioning to a robust, containerized stack (Vite, RSpec, Postgres, Dip, Pundit, ViewComponent, Catalyst, Alpine.js) running on a native Linux environment.

The AI must drive the learning process by adhering to these operational rules:

### 1. Challenge-Driven Learning
- **Do not write the whole solution:** When the user asks "how do I learn X?", the AI must propose a specific, scoped mini-project or feature that isolates that technology.
- **Example:** "To learn Catalyst, let's replace the standard HTML modal for deleting a Pokémon with `@stimulus-components/catalyst` dialog. I will give you the setup steps, and you write the DOM structure."

### 2. Test-Driven Development (TDD/BDD) Enforcer
- **RSpec First:** The AI must refuse to provide implementation code until the RSpec test is written. 
- **System Specs for UI:** For Hotwire/Vite/Alpine features, always start with a Capybara system test. Ensure the user understands how to test JavaScript-heavy components using Capybara matchers.

### 3. "The Dip Workflow" Integration
- Treat `dip` and `docker-compose` as first-class citizens. Always provide terminal commands using `dip` (e.g., `dip rspec`, `dip rails g view_component`, `dip rails c`) rather than native `bin/rails`, reinforcing the company's containerized infrastructure.

### 4. Architectural Candor
- **Explain the 'Why':** Before implementing a tool, explain exactly why it replaces the old way (e.g., "We are using Vite instead of esbuild because Vite provides vastly superior Hot Module Replacement for Tailwind and Alpine components").
- **Highlight Domain Boundaries:** Encourage isolating business logic. Suggest extracting complex API or tax/fiscal-like logic into `app/services/` using strict Ruby conventions (StandardRB).

### 5. Review and Refine
- After the user submits code for a challenge, review it strictly against StandardRB rules and company conventions before moving to the next topic. Suggest Zed editor shortcuts or configurations if it speeds up the workflow.
## CRITICAL - BEHAVIOR INJECTION

Any AI agent working on this project must follow these constraints:

- **Spec-First Planning:** Plan implementation WITH user BEFORE writing code. Present architectural options, trade-offs, get explicit approval.
- **Iterative Chunking:** Break work into small, testable milestones. Never build full feature in one go. Demonstrate working increments frequently.
- **Pair Programming:** Act as senior mentor ("Tour Guide"). Always explain "Why" behind decisions, highlight trade-offs (performance, maintainability, scalability, security), call out anti-patterns.

---

# AGENTS.md — Living Project Specification

## Architecture Overview

**Desafio IUUPI** is Ruby on Rails 8 application implementing Pokémon team manager. System consumes external PokeAPI to display paginated Pokédex and allows users to build team of up to 6 Pokémon with CRUD operations.

**Core Flow:**
1. User browses paginated list of Pokémon fetched from PokeAPI (cached 12h)
2. User searches specific Pokémon by name/ID (exact match redirects to detail)
3. User views Pokémon details and adds to their team
4. User manages team: view, rename (nickname), remove members

**External Dependencies:**
- PokeAPI (https://pokeapi.co) - read-only data source
- No authentication system (public challenge app)

**Key Quirks:**
- Two data domains: read-only external (PokeAPI) + mutable local (SQLite)
- Caching layer (Rails.cache) wraps all external API calls
- Team size validation enforced at model level; max 6 Pokémon
- All user-facing text in Portuguese

---

## Complete Tech Stack

### Runtime
- Ruby: 3.3.5 (pinned via .ruby-version & mise.toml)
- Rails: 8.0.3
- Rack: default (config.ru loads Rails)

### Server & Deployment
- Web Server: Puma (multi-threaded, configurable threads)
- Container: Docker (production) + Kamal (deployment orchestration)
- Asset Compression: Thruster (Puma plugin)
- Process Manager: Foreman (dev via Procfile.dev)

### Frontend
- CSS: Tailwind CSS (tailwindcss-rails gem)
- JavaScript: Importmap (no bundler; pins from CDN-like vendor assets)
- Hotwire: Turbo-Rails + Stimulus-Rails
- Asset Pipeline: Propshaft (Rails 8+ replacement for Sprockets)

### Data & Caching
- Database: SQLite3 (development/test/production)
- Caching: Solid Cache (production) / Memory Store (development)
- Background Jobs: Solid Queue (production; runs in-process with Puma when SOLID_QUEUE_IN_PUMA=true)
- WebSockets: Solid Cable (production; configured but not actively used)

### HTTP & Utilities
- HTTP Client: Faraday (PokeAPI integration)
- Pagination: Pagy (offset pagination)

### Development & Quality
- Linting: RuboCop with rubocop-rails-omakase
- Security: Brakeman (static analysis)
- Test: Minitest (default Rails) + Capybara + Selenium (system tests)
- Debug: debug gem (MRI platforms)
- Console: Web Console (development)

### Deployment & Ops
- Deploy: Kamal (Docker-based)
- CI/CD: GitHub Actions (.github/workflows/ci.yml)
- Secret Management: Kamal secrets + Rails credentials (config/credentials.yml.enc)
- Monitoring: Health check endpoint at `/up`

---

## Environment Variables Inventory

### Required / Commonly Used

| Variable | Purpose | Default / Env | Notes |
|----------|---------|---------------|-------|
| `RAILS_ENV` | Rails environment | development | Set to "test" or "production" as needed |
| `RAILS_MAX_THREADS` | Puma thread pool size | `5` | Also used by DB pool (database.yml) |
| `PORT` | Server port | `3000` (dev), `80` (prod) | Kamal exposes port 80 in production |
| `RAILS_LOG_LEVEL` | Logging verbosity | `"info"` (prod) | Set to `"debug"` for verbose logging |
| `RAILS_MASTER_KEY` | Decrypts credentials | Required in prod | Loaded from config/master.key or ENV |
| `SOLID_QUEUE_IN_PUMA` | Run queue worker in Puma | `true` (prod) | See config/deploy.yml; production uses in-process supervisor |
| `WEB_CONCURRENCY` | Puma workers (processes) | `1` (default) | Tune for multi-core servers |
| `KAMAL_REGISTRY_PASSWORD` | Docker registry auth | Required for deploy | Injected via .kamal/secrets |
| `RAILS_SERVE_STATIC_FILES` | Serve assets directly | Not explicitly set | Env var used by Rails in production with Puma/Thruster |

### Development-specific
- `RUBY_DEBUG_OPEN` = `"true"` (set by bin/dev)
- `RUBY_DEBUG_LAZY` = `"true"` (set by bin/dev)

### Not Used (but present in config)
- Email/SMTP settings are commented out in production.rb
- No external database (SQLite only, even in production)

---

## Directory and Content Structure

```
.
├── app/
│   ├── controllers/
│   │   ├── application_controller.rb      # Base controller (allow_browser :modern)
│   │   ├── pokemons_controller.rb         # Index (list), Show (detail)
│   │   └── team_pokemons_controller.rb    # Index, Create, Update (nickname), Destroy
│   ├── models/
│   │   ├── application_record.rb          # Base ActiveRecord class
│   │   └── team_pokemon.rb                # Validation: presence, uniqueness, max 6
│   ├── services/
│   │   └── poke_api_service.rb            # External API wrapper + caching
│   ├── views/
│   │   ├── pokemons/
│   │   │   ├── index.html.erb             # Grid list + pagination + search form
│   │   │   └── show.html.erb              # Detail + "capture to team" form
│   │   ├── team_pokemons/
│   │   │   └── index.html.erb             # Team grid + nickname edit + delete
│   │   └── layouts/
│   │       └── application.html.erb        # Not shown but standard Rails layout
│   ├── javascript/
│   │   ├── application.js                  # Importmap setup + Turbo/Stimulus imports
│   │   └── controllers/                    # Stimulus controllers (default hello_controller)
│   └── assets/
│       ├── images/                         # Static images (not used for Pokémon)
│       ├── stylesheets/                    # Tailwind CSS source (via tailwindcss-rails)
│       └── tailwind/                       # Tailwind config & generated CSS
├── config/
│   ├── routes.rb                           # root "pokemons#index", RESTful resources
│   ├── database.yml                        # SQLite config (3 envs: development/test/production)
│   ├── deploy.yml                          # Kamal deployment config (SSL, volumes, aliases)
│   ├── puma.rb                             # Threads, port, Solid Queue plugin
│   ├── importmap.rb                        # JS dependency pins
│   ├── storage.yml                         # Local Disk service (dev/test/prod)
│   ├── environments/
│   │   ├── development.rb                  # Reloading, caching off, verbose queries
│   │   ├── test.rb                         # Eager load on CI, caching disabled
│   │   └── production.rb                   # Solid Cache/Queue, logging to STDOUT, SSL off (Podman local)
│   ├── initializers/                       # Standard Rails initializers (inflections, CSP, etc.)
│   ├── application.rb                      # Autoload lib (ignore assets/tasks)
│   └── boot.rb                             # Bundler + Bootsnap setup
├── db/
│   ├── migrate/                            # Single migration: create_team_pokemons
│   ├── schema.rb                           # Auto-generated; single table team_pokemons
│   └── [storage/]                          # SQLite files live here (development.sqlite3, etc.)
├── test/
│   ├── test_helper.rb                      # Parallel test setup, fixtures :all
│   ├── models/team_pokemon_test.rb         # Empty test skeleton
│   └── application_system_test_case.rb     # Base for system tests (Capybara/Selenium)
├── lib/                                    # Empty/standard lib dir (autoloaded)
├── public/                                 # Static files (PWA manifest, service worker stub)
├── storage/                                # Local file storage (SQLite DBs + uploads)
├── log/                                    # Application logs
├── tmp/                                    # Temp files (PID, cache, etc.)
├── vendor/                                 # Not used (no vendored gems/assets)
├── .kamal/                                 # Deployment secrets + hooks (samples)
├── .github/
│   ├── workflows/ci.yml                    # CI: brakeman, importmap audit, rubocop, tests
│   └── dependabot.yml                      # Daily updates for bundler & GitHub Actions
├── bin/
│   ├── rails                               # Rails command entrypoint
│   ├── dev                                 # Foreman starter (Procfile.dev)
│   ├── setup                               # Idempotent setup: bundle, db:prepare, clear, exec dev
│   ├── rubocop                             # Style checker
│   ├── brakeman                            # Security scanner
│   ├── importmap                           # JS pin manager
│   ├── kamal                               # Deployment wrapper
│   └── thrust                              # Asset compression (Puma plugin)
├── script/                                 # Empty (no custom scripts)
├── Gemfile                                 # Dependencies (see below)
├── Gemfile.lock                            # Locked versions
├── Rakefile                                # Loads Rails tasks
├── Dockerfile                              # Multi-stage build for production (Kamal)
├── Procfile.dev                            # Foreman: web + css watcher
├── .ruby-version                           # ruby-3.3.5
├── mise.toml                               # mise tool version pin
├── .rubocop.yml                            # Inherits rubocop-rails-omakase
└── README.md                               # Challenge instructions (PT-BR)

### File Counts (approximate)
- Controllers: 2 (plus concerns/ empty)
- Models: 1 (plus ApplicationRecord)
- Services: 1 (PokeApiService)
- Views: 3 ERB templates
- Migrations: 1
- Tests: 2 (very sparse)
```

---

## Services, Jobs, and Models Mapping

### Models

| Model | Table | Validations | Notes |
|-------|-------|-------------|-------|
| `TeamPokemon` | team_pokemons | `pokemon_id` presence & uniqueness; `pokemon_name` presence; custom `team_size_limit` (max 6) | Columns: `pokemon_id` (string from API, unique), `pokemon_name`, `image_url`, `nickname`, timestamps |

**Note:** No `Team` or `User` model. Team is implicit singleton collection.

### Services

#### `PokeApiService`
- **Purpose:** Encapsulate all HTTP calls to PokeAPI with caching
- **Public Methods:**
  - `.fetch_list(page:, limit:)` → `{ count: Integer, results: [{ id, name, image_url }] }`
  - `.fetch_pokemon(id_or_name)` → `{ id, name, image_url }` or `nil`
- **Caching:** 12-hour TTL via `Rails.cache.fetch`
- **Base URL:** `https://pokeapi.co/api/v2`
- **Error Handling:** Returns `nil` on failed response (non-200); controllers handle redirect

### Jobs
- **None defined.** `solid_queue` gem included but not used.

### Background Processes
- `SolidQueue` supervisor optionally runs inside Puma (production). No jobs enqueued yet.

---

## 12 Common Hurdles (Workarounds & Gotchas)

### H1: No Test Coverage Beyond Skeletons
**Problem:** Test suite is essentially empty (one empty model test, skeleton system test).  
**Workaround:** Any change risks breaking functionality without detection.  
**Action:** Write integration/system tests covering:
  - Pagination edge cases (page 1, last page, beyond range)
  - Team add/remove/rename including max-6 validation
  - PokeAPI failure scenarios (service returns nil)
  - Search exact-match redirect behavior

Test command: `bin/rails test test:system` (but system tests may need Chrome installed; see H2).

---

### H2: System Tests Require Chrome
**Problem:** CI workflow installs `google-chrome-stable` explicitly; local dev may not have Selenium/WebDriver configured.  
**Workaround:** If running system tests locally fails due to missing driver, either install Chrome/Chromedriver or skip system tests: `bin/rails test` (excludes system).  
**Action:** For reliable local system tests, install Chrome or use headless Chromium. CI uses `google-chrome-stable` package.

---

### H3: External API Rate Limits & Caching
**Problem:** PokeAPI has rate limits; no retry/backoff logic in `PokeApiService`.  
**Workaround:** 12-hour Rails cache mitigates repeated calls, but burst traffic could exhaust rate limits.  
**Action:** Assume PokeAPI is generous (it's public educational API), but monitor for `429 Too Many Requests`. If encountered, add retry with exponential backoff using Faraday middleware or circuit breaker.

---

### H4: Team Uniqueness Validation Edge Cases
**Problem:** `TeamPokemon` validates `pokemon_id` uniqueness scoped to nothing (global uniqueness). Concurrent requests could create duplicate entries if two requests pass validation simultaneously.  
**Workaround:** Database-level unique index is NOT present (schema has no index). This is a race condition.  
**Action:** Add unique index on `team_pokemons(pokemon_id)` via migration before production. Also consider adding `null: false` constraint.

---

### H5: Search Redirect Behavior Is Overly Broad
**Problem:** `PokemonsController#index` redirects any non-blank `query` param to `pokemon_path(query.downcase)`, regardless of whether Pokémon exists. If user misspells name, they get 404 redirect loop or immediate redirect to show page that then fails.  
**Workaround:** Show action handles missing Pokémon by redirecting back with alert.  
**Action:** UX improvement: validate existence before redirect (client-side via JS debounce or server-side fetch-then-redirect). Currently causes unnecessary round-trip.

---

### H6: Pagination Uses Offset, Not Cursor
**Problem:** Pagy is configured as `Pagy::Offset` (offset/limit). Large offsets (page > 1000) become slow on PokeAPI side.  
**Workaround:** PokeAPI uses offset/limit; fine for small page numbers.  
**Action:** No immediate fix needed; challenge scope limited. If scaling, consider cursor-based pagination (PokeAPI doesn't support, so not applicable).

---

### H7: No CSRF Protection Customization
**Problem:** `ApplicationController` only sets `allow_browser versions: :modern`. Form authenticity tokens are at Rails defaults.  
**Workaround:** Should be fine; no APIs or JSON endpoints.  
**Action:** None needed. Verify that `protect_from_forgery` (default) is intact.

---

### H8: No Asset Host / CDN
**Problem:** Pokémon images come from raw.githubusercontent.com (PokeAPI sprites). Assets (CSS/JS) served locally via Propshaft.  
**Workaround:** None needed.  
**Implication:** If deploying with Kamal, Puma/Thruster will serve compiled Rails assets. Tailwind CSS compiled into single file.

---

### H9: Production Database is Still SQLite
**Problem:** Production uses SQLite with multiple databases (primary, cache, queue, cable) per config/database.yml (Solid gems). However, SQLite concurrency is limited (write locks).  
**Workaround:** Kamal's deployment runs single-container; low traffic ok.  
**Action:** Not suitable for high-concurrency production. Consider Postgres for multi-worker scaling. But challenge constraint says "do not alter database (SQLite)".

---

### H10: Kamal Config is Placeholder
**Problem:** `.kamal/config.yml` not versioned (directory listed but config not tracked). Secrets file `.kamal/secrets` has sample placeholders.  
**Workaround:** User must fill in `config/deploy.yml` and `.kamal/secrets` with real values for deployment.  
**Action:** Before deploying, configure:
  - `image: your-user/desafio_iuupi` → Docker Hub username
  - `servers.web[0]` → actual server IP
  - `proxy.ssl.host` → real domain
  - `KAMAL_REGISTRY_PASSWORD` env set in `.kamal/secrets`
  - `config/master.key` must be available for RAILS_MASTER_KEY extraction

---

### H11: No Rate Limiting / Abuse Protection
**Problem:** Team creation endpoint (`TeamPokemonsController#create`) is unprotected; anyone can spam adds.  
**Workaround:** Not relevant for coding challenge.  
**Action:** If deployed publicly, add Rack::Attack or similar throttle.

---

### H12: Environment-Specific SSL/Force SSL Disabled
**Problem:** `config/environments/production.rb` sets `config.assume_ssl = false` and `config.force_ssl = false` explicitly to allow local testing via Podman on localhost.  
**Workaround:** Works for dev/test; **SECURITY RISK** if deployed to public Internet without SSL.  
**Action:** Set both to `true` in real production with proper certificates. Kamal config sets `proxy.ssl: true`, but Rails must be configured to trust proxy and enforce SSL.

---

## Design Patterns Utilized

| Pattern | Location | Explanation |
|---------|----------|-------------|
| Service Object | `app/services/poke_api_service.rb` | Extracts external API logic from controllers; single responsibility; testable in isolation |
| Form Object (lightweight) | `form_with model: TeamPokemon.new` in show view | Uses ActiveRecord model directly as form object; acceptable for simple create (no separate form class) |
| Pagination Pattern | `Pagy::Offset` in PokemonsController | Explicit count + page params; view renders prev/next links conditionally |
| Cache-Aside | `Rails.cache.fetch` in service | Read-through cache; 12h TTL; avoids repeated API calls |
| Redirect-After-Post (PRG) | `TeamPokemonsController` actions | `redirect_to` with `status: :see_other` (303) pattern post-Create/Update/Destroy |
| Validation Callback | `TeamPokemon#team_size_limit` | Custom validation method instead of database-level constraint (see H4) |
| Singleton Collection Implicit | Team management (no Team model) | Collection is implicit; all TeamPokemon records treated as "the team" |

**Anti-Patterns Noted:**
- No repository/data-mapper pattern; controllers call service directly (OK for small app)
- Active Record used as both domain model and form object (acceptable here, but would separate for complex forms)
- No explicit policy/authorization (not needed for challenge)

---

## Core Pipelines & Workflows

### Development Workflow

1. **Setup (one-time or after clone):**
   ```bash
   bin/setup               # Installs gems, prepares DB, starts server (unless --skip-server)
   ```
   - Runs `bundle check` → `bundle install` if needed
   - Runs `bin/rails db:prepare` (creates/ migrates DB)
   - Clears logs/tmp
   - Starts Foreman: `bin/dev`

2. **Running the app:**
   ```bash
   bin/dev                 # Starts web server + Tailwind CSS watcher via Foreman
   # OR
   bin/rails server        # Direct Puma start (no CSS auto-watch)
   ```
   - `bin/dev` reads `Procfile.dev`:
     - `web: bin/rails server`
     - `css: bin/rails tailwindcss:watch`

3. **Database operations:**
   ```bash
   bin/rails db:create      # Creates SQLite files (not needed; db:prepare handles)
   bin/rails db:migrate     # Runs single migration
   bin/rails db:seed        # No seeds defined
   bin/rails db:reset       # Drops & recreates DB (test/dev only)
   bin/rails db:test:prepare # Prepares test DB from schema
   ```

4. **Testing:**
   ```bash
   bin/rails test                    # Runs all Minitest tests (model + others)
   bin/rails test:system             # Runs system tests (requires Chrome)
   bin/rails test test/models/team_pokemon_test.rb  # Single file
   ```
   - Parallelized by default (workers = CPU count)
   - Fixtures loaded automatically (`fixtures :all`)

5. **Linting & Security:**
   ```bash
   bin/rubocop -f github             # Lint with GitHub Actions format
   bin/brakeman --no-pager           # Security scan
   bin/importmap audit               # Check JS dependencies for vulnerabilities
   ```
   - These commands mirror CI steps; run locally before pushing.

6. **Console & Debugging:**
   ```bash
   bin/rails console                 # IRB with app context
   bin/rails dbconsole               # Direct SQLite CLI
   ```

---

### CI/CD Pipeline (.github/workflows/ci.yml)

Runs on every push to `main` and PRs. Jobs run in parallel:

1. **scan_ruby** – Runs `bin/brakeman --no-pager`
2. **scan_js** – Runs `bin/importmap audit`
3. **lint** – Runs `bin/rubocop -f github`
4. **test** – Installs dependencies + Chrome, runs `bin/rails db:test:prepare test test:system`
   - Uploads screenshots on system test failure

**Order matters:** lint and scan jobs don't depend on each other; test depends on successful setup.

---

### Production Deployment (Kamal)

1. **Configure secrets:**
   - Ensure `.kamal/secrets` has correct `KAMAL_REGISTRY_PASSWORD` and reads `config/master.key`.
   - `config/deploy.yml` must have correct `image`, `servers`, `proxy.host`, `registry.username`.

2. **Build & deploy:**
   ```bash
   bin/kamal build      # Builds Docker image (multi-stage)
   bin/kamal deploy     # Deploys to configured servers
   bin/kamal upgrade    # Same as deploy (alias)
   ```

3. **Common aliases (from deploy.yml):**
   ```bash
   bin/kamal console    # Rails console on server
   bin/kamal logs       # Tail logs
   bin/kamal dbc        # Database console
   ```

4. **Traefik proxy** – Kamal sets up Traefik as reverse proxy with Let's Encrypt SSL if `proxy.ssl: true`.

**Important:** Production uses **multiple SQLite databases** via database.yml (primary, cache, queue, cable). Dockerfile copies app code and precompiles assets. Entrypoint `bin/docker-entrypoint` (not inspected here) prepares DB.

---

## Command Reference Cheat Sheet (Exact Commands)

### Development Start
```bash
# First-time setup
bin/setup                           # Idempotent setup + server start
# If you already have gems/DB, skip server:
bin/setup --skip-server

# Just start server (without CSS watcher)
bin/rails server

# With CSS auto-recompilation (recommended)
bin/dev
```

### Database
```bash
bin/rails db:prepare                # Create/migrate (safe to run repeatedly)
bin/rails db:migrate                # Run pending migrations
bin/rails db:rollback STEP=1        # Undo last migration
bin/rails db:schema:load           # Load schema.rb (test/prod)
bin/rails db:test:prepare          # Prepare test DB
bin/rails db:reset                 # Drop + create + migrate
```

### Testing
```bash
# Full test suite (parallelized)
bin/rails test

# Single test file
bin/rails test test/models/team_pokemon_test.rb

# Single test method (line number)
bin/rails test test/models/team_pokemon_test.rb:5

# System tests (requires Chrome/Chromedriver)
bin/rails test:system

# With CI-like eager loading (detect loading issues)
CI=1 bin/rails test
```

### Code Quality
```bash
# Lint (fixable offenses auto-corrected)
bin/rubocop -a

# Lint with GitHub Actions annotation format
bin/rubocop -f github

# Security scan
bin/brakeman --no-pager

# Check JS dependencies
bin/importmap audit
```

### Console & Debug
```bash
bin/rails console                   # Main console
bin/rails dbconsole                 # SQLite CLI (development)
# Production console via Kamal:
bin/kamal console
```

### Deployment
```bash
# Build only
bin/kamal build

# Deploy (build + release)
bin/kamal deploy

# Rollback (via kamal [rollback|undo] commands if needed; check kamal --help)
```

### Misc
```bash
# Clear logs/tmp
bin/rails log:clear tmp:clear

# Precompile assets (Rails does this automatically in production via Dockerfile)
bin/rails assets:precompile

# Routes list
bin/rails routes
```

---

## Required Command Order & Rationale

- **DB setup:** `bin/rails db:prepare` is safe to run repeatedly (creates if missing, migrates if needed). Use it over `db:create` + `db:migrate` separately.
- **Before pushing:** Run `bin/rubocop -f github` → `bin/brakeman --no-pager` → `bin/rails test` (mirrors CI order: lint → security → tests).
- **System tests:** Must run after `db:test:prepare` (handled by `rails test` automatically).
- **Production deploy:** Kamal `build` → `deploy` sequence; never `docker run` manually (use Kamal to manage SSL, volumes, secrets).
- **Asset compilation:** Happens automatically in Docker build (see Dockerfile line 49: `SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile`).

---

## Multi-Package Boundaries & Ownership

**Single-repo, single-app:** No monorepo or engines. Entire codebase under one Rails application namespace `DesafioIuupi`.

- **API Layer:** `app/services/poke_api_service.rb` owns all external HTTP communication.
- **Domain Logic:** `app/models/team_pokemon.rb` owns team rules (max size, uniqueness).
- **Web Layer:** Controllers own request/response plumbing; views own presentation.
- **No JS packages or NPM** – Importmap manages vendor JS from CDN-like vendor/assets.

---

## Framework/Toolchain Quirks

### Rails 8 Specifics
- **Propshaft** replaces Sprockets. `app/assets` still works, but no `asset_path` helpers in views for fingerprinted assets (not used here).
- **Importmap** – No `yarn`/`npm`. Dependencies pinned in `config/importmap.rb`. `bin/importmap` manages pins.
- **Solid gems** – Replace Redis/Postgres in production. SQLite is used for all databases (primary, cache, queue, cable). They create separate database files per environment (e.g., `storage/production_cache.sqlite3`).
- **Thruster** – Compresses assets on-the-fly in development and serves precompiled assets in production (Docker CMD uses `./bin/thrust`).

### Kamal Quirks
- **Secrets file**: `.kamal/secrets` must be safe for git (no raw credentials). Uses `$(kamal secrets extract ...)` pattern or direct `ENV` refs.
- **Volumes**: `desafio_iuupi_storage:/rails/storage` persists SQLite DB and uploads.
- **Proxy SSL**: Traefik handles SSL termination; Rails `config.assume_ssl = false` intentionally for local Podman tests. In real production, set `config.assume_ssl = true` behind proxy.

### Tailwind CSS
- `tailwindcss-rails` gem compiles CSS at build time (no external Postgres/Node required).
- Styles live in `app/assets/stylesheets/application.tailwind.css` (generated implicitly).
- Customizations go in `app/assets/tailwind/` (config.js, etc.) – already present.

### Turbo/Stimulus
- Turbo Drive handles navigation; links in app are regular Rails links, but Turbo intercepts.
- `button_to` with `data: { turbo_confirm: ... }` in team delete uses Turbo confirm dialog.
- No custom Stimulus controllers beyond `hello_controller` scaffold.

### Caching
- `Rails.cache.fetch` keys: `"pokemons_page_#{page}_limit_#{limit}"`, `"pokemon_#{id_or_name}"`.
- 12-hour expiration (`expires_in: 12.hours`).
- Cache store:
  - Dev: `:memory_store`
  - Prod: `:solid_cache_store` (persisted to SQLite `storage/production_cache.sqlite3`)

---

## Infrastructure & Config Files

### .kamal/secrets
- Sample hooks exist in `.kamal/hooks/` (docker-setup.sample, pre-build.sample, post-deploy.sample, etc.). Rename to remove `.sample` to activate.
- Current file sets:
  ```bash
  KAMAL_REGISTRY_PASSWORD=$KAMAL_REGISTRY_PASSWORD
  RAILS_MASTER_KEY=$(cat config/master.key)
  ```

### Dockerfile
- Multi-stage build: `base` → `build` → final.
- Base installs: curl, libjemalloc2, libvips, sqlite3.
- Build stage installs build-essential + gems + precompiles assets/bootsnap.
- Final stage runs as non-root user `rails` (UID 1000).
- Entrypoint: `/rails/bin/docker-entrypoint` (prepares DB, runs migrations?).
- CMD: `./bin/thrust ./bin/rails server` (Thruster + Puma).

### config/deploy.yml
- Service name: `desafio_iuupi`
- Image: `your-user/desafio_iuupi` → must change to your Docker Hub username.
- Traefik proxy: `ssl: true`, `host: app.example.com` → change host.
- Env secrets: `RAILS_MASTER_KEY` injected.
- Clear env: `SOLID_QUEUE_IN_PUMA: true`.
- Volume: `desafio_iuupi_storage:/rails/storage`.

### GitHub Actions CI
- Matrix of separate jobs (scan_ruby, scan_js, lint, test).
- Uses `ruby/setup-ruby@v1` with bundler-cache.
- Chrome installed for system tests.
- Artifacts: screenshots upload on failure.

---

## Important Patterns & Conventions

### Portuguese Naming
- All UI strings in Portuguese (views, flash messages, validations).
- Model attribute names are English (Rails convention) but displayed localized.

### Flash Messages
- Redirects use `notice:` for success, `alert:` for errors.
- `status: :see_other` (303) used consistently for POST/PUT/DELETE redirects.

### Parameter Whitelisting
- `team_pokemons_params` & `nickname_params` use strong params (`require` + `permit`).

### Pagination
- `Pagy::Offset` instantiated manually: `Pagy::Offset.new(count: ..., page: page, items: limit)`.
- View checks `@pagy.page`, `@pagy.next` (boolean; presence implies next page available).

### Caching Keys
- Namespaced with operation (`pokemons_page_`, `pokemon_`). If API data changes, need manual cache clearing or TTL expiry.

### External HTTP Calls
- Always through `PokeApiService` (Faraday). No direct HTTP in controllers.

### Validation
- `team_size_limit` custom validator runs on `:create` only (team size enforced at addition, not update).
- Uniqueness validation `pokemon_id` at model level (no DB index yet – see H4).

---

## Missing / To-Do Items (Detected)

- [ ] **Tests:** Comprehensive test suite (currently < 10 LOC effective tests). Add:
  - Controller tests for PokemonsController (index, show, search redirect)
  - Controller tests for TeamPokemonsController (all CRUD, validation errors)
  - Integration test: full flow search → add → rename → delete
  - System tests for UI interactions (Turbo, forms)
- [ ] **Database constraints:** Add unique index on `team_pokemons(pokemon_id)`; maybe not-null constraints.
- [ ] **Retry logic**: PokeAPI service should handle transient failures (Faraday retry middleware).
- [ ] **Better search UX:** Avoid redirect for non-existent Pokémon; show "not found" inline.
- [ ] **Rate limiting:** Consider Rack::Attack if public-facing.
- [ ] **Production SSL:** Set `config.force_ssl = true` and `config.assume_ssl = true` when behind Traefik (currently false for local Podman testing).
- [ ] **Kamal config finalization**: Populate real values (image name, server IP, domain, registry credentials).
- [ ] **Accessibility audit:** Ensure forms have proper labels, alt text for images is present (it is: uses Pokémon name), color contrast (Tailwind defaults OK).

---

## File Tree (Concise - Key Files Only)

```
 Gemfile                  → dependencies (Rails 8, Puma, SQLite3, Propshaft, Importmap, Turbo, Stimulus, Tailwind, Pagy, Faraday, Solid*, Kamal, Thruster)
 .ruby-version            → ruby-3.3.5
 mise.toml                → ruby = "3.3.5"
 config.ru                → Rack entrypoint
 Rakefile                 → loads Rails tasks
 config/
   application.rb         → Rails defaults 8.0, autoload lib (ignore assets/tasks)
   boot.rb                → Bundler + Bootsnap
   environment.rb         → initialize!
   routes.rb              → root pokemons#index; resources pokemons (index,show), team_pokemons (index,create,update,destroy)
   database.yml           → SQLite (development: storage/development.sqlite3, test: storage/test.sqlite3, production: primary+cache+queue+cable)
   deploy.yml             → Kamal config (servers, proxy, env, volumes, aliases)
   puma.rb                → threads (RAILS_MAX_THREADS, default 3), port (PORT), solid_queue plugin
   importmap.rb           → pins for turbo/stimulus + controllers
   storage.yml            → Disk service (root: storage/ or tmp/storage/)
   environments/
     development.rb       → reloading true, caching false, query logging
     test.rb              → eager_load on CI, caching null_store
     production.rb        → eager_load true, solid_cache_store, solid_queue, STDOUT logger, assume_ssl=false (override for podman)
   initializers/          → standard Rails initializers (CSP, filter parameter logging, inflections, assets)
 app/
   controllers/           → PokemonsController, TeamPokemonsController
   models/                → TeamPokemon (+ validation)
   services/              → PokeApiService (cached external API client)
   views/                 → ERB templates (Tailwind classes)
   javascript/            → Importmap entry + Stimulus controllers (default hello_controller)
   assets/                → Tailwind CSS sources + images
 config/
   credentials.yml.enc    → encrypted credentials (not checked in; master.key ignored)
   master.key             → NOT in repo (.gitignore) – required for production credentials
 db/
   migrate/               → 20260314215210_create_team_pokemons.rb
   schema.rb              → single table team_pokemons
 test/
   test_helper.rb         → parallelize, fixtures :all
   models/team_pokemon_test.rb    → empty
   application_system_test_case.rb → system test base
 .github/workflows/
   ci.yml                  → brakeman, importmap audit, rubocop, test (with Chrome)
   dependabot.yml          → daily bundler & github-actions updates
 .kamal/
   secrets                 → KAMAL_REGISTRY_PASSWORD, RAILS_MASTER_KEY sourcing
   hooks/                  → sample hook scripts (docker-setup.sample, pre-build.sample, post-deploy.sample, …)
 bin/
   rails, dev, setup, rubocop, brakeman, importmap, kamal, thrust, bundle, rake
 Dockerfile                → multi-stage build (base, build, final); non-root user rails; entrypoint; thrust CMD
 Procfile.dev              → foreman: web + css watcher
 README.md                 → challenge spec (PT-BR; no IA, no extra gems except faraday/pagy)
 AGENTS.md                 ← this file (living specification)
```

---

## Quick Start for New Devs

```bash
# 1. Clone + install Ruby 3.3.5 (use rbenv/rvm/mise)
mise install                    # if using mise (reads .mise.toml)
# OR rbenv install 3.3.5 && rbenv local 3.3.5

# 2. Install gems & setup DB
bin/setup                       # runs bundle install + db:prepare + starts server

# 3. Visit http://localhost:3000
# - Browse Pokédex
# - Search by name/ID
# - Add Pokémon to team (max 6)
# - Rename/remove from team page

# 4. Run tests & linters before committing
bin/rails test
bin/rubocop -f github
bin/brakeman --no-pager

# Optional: run system tests (requires Chrome)
bin/rails test:system
```

---

## Unknowns / Open Questions

- **Are there any team conventions not captured here?** (code style beyond RuboCop omakase, commit message format, branch naming)
- **What's intended Git workflow?** (GitHub Flow? trunk-based? PR reviews mandatory?)
- **Is there project management board?** (Not in repo; no issues or project boards linked)
- **Where should new services be placed?** `app/services/` appears appropriate; currently only one.
- **Are there performance benchmarks or load expectations?** Challenge doesn't specify traffic scale.

If any of these matter, please clarify and I'll incorporate them into this AGENTS.md.

---

*Last updated: 2026-04-14 (auto-generated from repository analysis)*
