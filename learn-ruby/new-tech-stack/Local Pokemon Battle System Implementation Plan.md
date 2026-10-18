## User

> Read the AGENTS.md file.
> I want to add a new screen that will be able to do a local battle sistem that player 1 will be able to create a team pokemon > 1 and < 6. The player will be able to chosse a pokemon and choose the attack it will have. After that the player 2 will take control and it will do the same thing. Now there will be 2 url, each for each player and in real time for each turn the feedback of the health bar and the log of each move will be on the scream
> Create a plan of the first steps that I will need to do it

## Assistant

<thinking>
The user wants to add a local battle system to the Pokémon app. Let me understand the requirements:

1. Two players, each creates a team of 1-6 Pokémon (max 6 total, min 1 total)
2. Each player selects Pokémon and their attacks
3. Two URLs, one for each player
4. Real-time health bars and battle log on screen
5. Turn-based battle system

This is a significant new feature. Let me think about what needs to be planned:

1. **Data Model Changes**:
   - Need a `Battle` model to track battle state
   - Need a `BattleTeam` model (or use existing TeamPokemon but with a battle context)
   - Need an `Attack` model (or we can use moves from PokeAPI)
   - Need a `BattleLog` or `BattleTurn` model to track move history

2. **API/Service Layer**:
   - Need to fetch Pokémon moves from PokeAPI
   - Need a battle simulation service

3. **Controllers**:
   - `BattlesController` for creating/managing battles
   - Need to handle player 1 and player 2 flows

4. **Views**:
   - Battle creation screen (player 1)
   - Battle join/setup screen (player 2)
   - Battle arena view with health bars and battle log

5. **Real-time Updates**:
   - This is the tricky part - need WebSocket or polling for real-time updates
   - The app uses Solid Cable (ActionCable compatible) but "not actively used"
   - Could use Turbo Streams or ActionCable for real-time

6. **Game Logic**:
   - Turn-based battle system
   - HP calculation
   - Damage calculation
   - Win/lose conditions

Let me create a plan for the first steps. According to AGENTS.md, I should follow XP practices - spec-first planning, iterative chunking.

First step would be to understand the existing structure better and then propose a plan. Let me look at the existing models and services to understand what we're working with.

</thinking>

Let me first understand the current codebase structure to plan this properly.


**Tool Call: Read file `AGENTS.md`**
Status: Completed

```new-tech-stack/AGENTS.md
SUCCESS: File outline retrieved. This file is too large to read all at once, so the outline below shows the file's structure with line numbers.

IMPORTANT: Do NOT retry this call without line numbers - you will get the same outline.
Instead, use the line numbers below to read specific sections by calling this tool again with start_line and end_line parameters.

# File outline for /home/calvet/Projetos/PESSOAIS/learn-new-languages/learn-ruby/new-tech-stack/AGENTS.md

# 🤖 AI Behavior (Modern Extrem Programming Mentor) [L1-36]
 ## 🧠 AI Learning Mentor Guidelines (IUUPI Stack Migration) [L3-26]
  ### 1. Challenge-Driven Learning [L9-13]
  ### 2. Test-Driven Development (TDD/BDD) Enforcer [L13-17]
  ### 3. "The Dip Workflow" Integration [L17-20]
  ### 4. Architectural Candor [L20-24]
  ### 5. Review and Refine [L24-26]
 ## CRITICAL - BEHAVIOR INJECTION [L26-36]
# AGENTS.md — Living Project Specification [L36-785]
 ## Architecture Overview [L38-60]
 ## Complete Tech Stack [L60-104]
  ### Runtime [L62-67]
  ### Server & Deployment [L67-73]
  ### Frontend [L73-79]
  ### Data & Caching [L79-85]
  ### HTTP & Utilities [L85-89]
  ### Development & Quality [L89-96]
  ### Deployment & Ops [L96-104]
 ## Environment Variables Inventory [L104-130]
  ### Required / Commonly Used [L106-120]
  ### Development-specific [L120-124]
  ### Not Used (but present in config) [L124-130]
 ## Directory and Content Structure [L130-222]
 ## Services, Jobs, and Models Mapping [L222-251]
  ### Models [L224-232]
  ### Services [L232-243]
   #### `PokeApiService` [L234-243]
  ### Jobs [L243-246]
  ### Background Processes [L246-251]
 ## 12 Common Hurdles (Workarounds & Gotchas) [L251-348]
  ### H1: No Test Coverage Beyond Skeletons [L253-266]
  ### H2: System Tests Require Chrome [L266-273]
  ### H3: External API Rate Limits & Caching [L273-280]
  ### H4: Team Uniqueness Validation Edge Cases [L280-287]
  ### H5: Search Redirect Behavior Is Overly Broad [L287-294]
  ### H6: Pagination Uses Offset, Not Cursor [L294-301]
  ### H7: No CSRF Protection Customization [L301-308]
  ### H8: No Asset Host / CDN [L308-315]
  ### H9: Production Database is Still SQLite [L315-322]
  ### H10: Kamal Config is Placeholder [L322-334]
  ### H11: No Rate Limiting / Abuse Protection [L334-341]
  ### H12: Environment-Specific SSL/Force SSL Disabled [L341-348]
 ## Design Patterns Utilized [L348-367]
 ## Core Pipelines & Workflows [L367-464]
  ### Development Workflow [L369-424]
  ### CI/CD Pipeline (.github/workflows/ci.yml) [L424-438]
  ### Production Deployment (Kamal) [L438-464]
 ## Command Reference Cheat Sheet (Exact Commands) [L464-556]
  ### Development Start [L466-480]
  ### Database [L480-490]
  ### Testing [L490-508]
  ### Code Quality [L508-523]
  ### Console & Debug [L523-531]
  ### Deployment [L531-542]
  ### Misc [L542-556]
 ## Required Command Order & Rationale [L556-566]
 ## Multi-Package Boundaries & Ownership [L566-577]
 ## Framework/Toolchain Quirks [L577-609]
  ### Rails 8 Specifics [L579-585]
  ### Kamal Quirks [L585-590]
  ### Tailwind CSS [L590-595]
  ### Turbo/Stimulus [L595-600]
  ### Caching [L600-609]
 ## Infrastructure & Config Files [L609-643]
  ### .kamal/secrets [L611-619]
  ### Dockerfile [L619-627]
  ### config/deploy.yml [L627-635]
  ### GitHub Actions CI [L635-643]
 ## Important Patterns & Conventions [L643-672]
  ### Portuguese Naming [L645-649]
  ### Flash Messages [L649-653]
  ### Parameter Whitelisting [L653-656]
  ### Pagination [L656-660]
  ### Caching Keys [L660-663]
  ### External HTTP Calls [L663-666]
  ### Validation [L666-672]
 ## Missing / To-Do Items (Detected) [L672-689]
 ## File Tree (Concise - Key Files Only) [L689-745]
 ## Quick Start for New Devs [L745-772]
 ## Unknowns / Open Questions [L772-785]

Showing symbols 1-80 (total symbols: 80)


NEXT STEPS: To read a specific symbol's implementation, call read_file with the same path plus start_line and end_line from the outline above.
For example, to read a function shown as [L100-150], use start_line: 100 and end_line: 150.
```


**Tool Call: List the `new-tech-stack/app/models` directory's contents**
Status: Completed

# Folders:
new-tech-stack/app/models/concerns

# Files:
new-tech-stack/app/models/application_record.rb
new-tech-stack/app/models/team_pokemon.rb


**Tool Call: List the `new-tech-stack/app/services` directory's contents**
Status: Completed


# Files:
new-tech-stack/app/services/poke_api_service.rb


**Tool Call: List the `new-tech-stack/app/controllers` directory's contents**
Status: Completed

# Folders:
new-tech-stack/app/controllers/concerns

# Files:
new-tech-stack/app/controllers/application_controller.rb
new-tech-stack/app/controllers/pokemons_controller.rb
new-tech-stack/app/controllers/team_pokemons_controller.rb


## Assistant

<thinking>
Good, I have a clear picture of the project. Let me read the key files to understand the current implementation before planning.

</thinking>

**Tool Call: Read file `app/models/team_pokemon.rb`**
Status: Completed

```new-tech-stack/app/models/team_pokemon.rb
class TeamPokemon < ApplicationRecord
  validates :pokemon_id, presence: true, uniqueness: { message: "já está no time" }
  validates :pokemon_name, presence: true

  validate :team_size_limit, on: :create

  private

  def team_size_limit
    if TeamPokemon.count >= 6
      errors.add(:base, "Time já possui o máximo de 6 pokemon")
    end
  end
end

```


**Tool Call: Read file `app/services/poke_api_service.rb`**
Status: Completed

```new-tech-stack/app/services/poke_api_service.rb
class PokeApiService
  BASE_URL = "https://pokeapi.co/api/v2".freeze

  def self.fetch_list(page: 1, limit: 20)
    offset = (page.to_i - 1) * limit

    Rails.cache.fetch("pokemons_page_#{page}_limit_#{limit}", expires_in: 12.hours) do
      response = Faraday.get("#{BASE_URL}/pokemon", { limit: limit, offset: offset })
      data = JSON.parse(response.body)

      results = data["results"].map do |poke|
        id = poke["url"].split("/").last
        {
          "id" => id,
          "name" => poke["name"],
          "image_url" => "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/#{id}.png"
        }
      end

      { count: data["count"], results: results }
    end
  end

  def self.fetch_pokemon(id_or_name)
    Rails.cache.fetch("pokemon_#{id_or_name}", expires_in: 12.hours) do
      response = Faraday.get("#{BASE_URL}/pokemon/#{id_or_name.to_s.downcase}")

      return nil unless response.success?

      data = JSON.parse(response.body)
      {
        "id" => data["id"].to_s,
        "name" => data["name"],
        "image_url" => data.dig("sprites", "front_default") || ""
      }
    end
  end
end

```


**Tool Call: Read file `config/routes.rb`**
Status: Completed

```new-tech-stack/config/routes.rb
Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  root "pokemons#index"

  resources :pokemons, only: [ :index, :show ]

  resources :team_pokemons, only: [ :index, :create, :update, :destroy ]
end

```


## Assistant

<thinking>
Now I have a good understanding of the current state. Let me look at the views to understand the current UI pattern.

</thinking>

**Tool Call: List the `new-tech-stack/app/views/pokemons` directory's contents**
Status: Completed


# Files:
new-tech-stack/app/views/pokemons/index.html.erb
new-tech-stack/app/views/pokemons/show.html.erb


**Tool Call: List the `new-tech-stack/app/views/team_pokemons` directory's contents**
Status: Completed


# Files:
new-tech-stack/app/views/team_pokemons/index.html.erb


**Tool Call: Read file `config/database.yml`**
Status: Completed

```new-tech-stack/config/database.yml
# SQLite. Versions 3.8.0 and up are supported.
#   gem install sqlite3
#
#   Ensure the SQLite 3 gem is defined in your Gemfile
#   gem "sqlite3"
#
default: &default
  adapter: sqlite3
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  timeout: 5000

development:
  <<: *default
  database: storage/development.sqlite3

# Warning: The database defined as "test" will be erased and
# re-generated from your development database when you run "rake".
# Do not set this db to the same as development or production.
test:
  <<: *default
  database: storage/test.sqlite3


# Store production database in the storage/ directory, which by default
# is mounted as a persistent Docker volume in config/deploy.yml.
production:
  primary:
    <<: *default
    database: storage/production.sqlite3
  cache:
    <<: *default
    database: storage/production_cache.sqlite3
    migrations_paths: db/cache_migrate
  queue:
    <<: *default
    database: storage/production_queue.sqlite3
    migrations_paths: db/queue_migrate
  cable:
    <<: *default
    database: storage/production_cable.sqlite3
    migrations_paths: db/cable_migrate

```


## Assistant

<thinking>
Now I have a good picture. Let me create a plan for this battle system.

Key requirements from user:
1. Local battle system (same machine/browser)
2. Player 1 creates team (1-5 Pokémon), chooses attacks
3. Player 2 does same thing (takes control)
4. 2 URLs, one per player, real-time health bars and move log

Tech stack analysis:
- Rails 8, SQLite (no multi-connection)
- Turbo/Stimulus for real-time (no WebSocket yet - Solid Cable is present but not used)
- No auth system
- Portuguese UI

This is a big feature. Need to plan incrementally with test-first approach.

Here's my plan:

**Phase 1: Data Model**
- New model: `Battle`, `BattleTeam`, `BattlePokemon` (or extend existing)
- Need attack data - could mock some moves or fetch from PokeAPI
- Need health tracking per battle

**Phase 2: Battle Flow Controller**
- `BattlesController` with: new, setup (player 1), join (player 2), play, attack, end
- Session-based player identification (player1_token, player2_token)
- Game state machine: waiting_for_player2 → waiting_for_p1_action → waiting_for_p2_action → battle_over

**Phase 3: Real-time Updates**
- Using Turbo Streams + ActionCable (Solid Cable is present)
- Health bars via Stimulus
- Battle log as turbo stream

**Phase 4: UI Views**
- Battle setup screen (select Pokémon, select moves)
- Battle arena screen (two sides, health bars, log)
- Each player has unique URL with token

Let me write this plan for user in caveman mode.

</thinking>

# Battle System Plan

### Architecture Overview

You need real-time battle between 2 players on same machine. Current stack has Turbo + Stimulus but no active WebSocket (Solid Cable present but not used). Two approaches:

1. **Polling (simpler):** JS polls every 2s, updates health bar + log
2. **ActionCable (better):** Turbo Streams over WebSocket, instant updates

I'll recommend polling initially (faster to build), upgrade to Cable later.

---

## Phase 1: Data Model (TDD first)

**Files to create:**
- `db/migrate/XXXX_create_battles.rb` — tracks: `player1_token`, `player2_token`, `status` (waiting/ready/active/finished), `current_turn`, `winner`
- `db/migrate/XXXX_create_battle_teams.rb` — `battle_id`, `player_token`, `team_size`, `position` (p1/p2)
- `db/migrate/XXXX_create_battle_pokemons.rb` — `battle_team_id`, `pokemon_id`, `pokemon_name`, `hp`, `max_hp`, `position_in_team`

**Attacks:** Use hardcoded mock (4 moves per Pokémon type) or fetch moves from PokeAPI `/pokemon/{id}/moves`.

```ruby
# app/models/battle.rb
class Battle < ApplicationRecord
  enum :status, { waiting: 0, ready: 1, active: 2, finished: 3 }
  has_many :battle_teams
  has_many :battle_pokemons, through: :battle_teams
end
```

---

## Phase 2: Battle Flow Controller

**`BattlesController`:**

| Action | Route | Purpose |
|--------|-------|---------|
| `new` | `GET /battles/new` | Creates battle, generates `player1_token`, redirects to setup |
| `join` | `GET /battles/:id/join` | Player 2 joins, gets `player2_token`, both redirect to setup |
| `setup` | `GET /battles/:id/setup?player_token=X` | Select 1-5 Pokémon + moves (player 1 and 2 separate URLs) |
| `ready` | `POST /battles/:id/ready` | Both ready → status=active, redirect to battle |
| `play` | `GET /battles/:id/play?player_token=X` | Main battle screen |
| `attack` | `POST /battles/:id/attack` | Execute move, switch turn, broadcast update |
| `end` | `POST /battles/:id/end` | Manual surrender |

**Token strategy:** Random 16-char hex in session/URL param. URL = `/battles/1?token=abc123`.

---

## Phase 3: Real-time (Polling)

**`app/views/battles/play.html.erb` + Stimulus controller:**

```javascript
// app/javascript/controllers/battle_controller.js
export default class extends Controller {
  static values = { battleId: String, playerToken: String }
  
  connect() {
    this.poll = setInterval(() => this.fetchState(), 2000)
  }
  
  async fetchState() {
    const res = await fetch(`/battles/${this.battleIdValue}/state?token=${this.playerTokenValue}`)
    const data = await res.json()
    // update health bars, log
  }
}
```

**Endpoint:** `GET /battles/:id/state` returns JSON with:
- Both teams' Pokémon (hp, max_hp, alive status)
- Current turn (p1/p2)
- Battle log (last 10 entries)

---

## Phase 4: UI Screens

1. **Setup screen** (`/battles/:id/setup?token=X`): Grid of player's captured Pokémon (from `team_pokemons`), click to select, choose 4 moves from type-compatible list. Show "Ready" button when 1-5 selected.

2. **Battle arena** (`/battles/:id/play?token=X`): Two columns (P1 left, P2 right), each shows team Pokémon with health bars. Center: action buttons (which Pokémon, which move). Bottom: scrolling log.

3. **Turn flow:** Select active Pokémon → Select move → Submit → Animation → Opponent's turn.

---

## First Steps (start here)

1. **Write migration specs** — what columns/tables needed. I'll write RSpec for this.

2. **Create migration** — run `dip rails g migration CreateBattles ...`

3. **Create models** — Battle, BattleTeam, BattlePokemon with associations

4. **Build `BattlesController#new`** — creates battle, generates player1 token, redirects to setup

5. **Build setup view** — fetch player's team_pokemons, render selection UI

6. **Add polling endpoint** — `state` action returns JSON

7. **Build battle arena view** — health bars + log + action buttons

---

## Questions Before Starting

1. **Attack data source:** Fetch moves from PokeAPI (`/pokemon/{id}/moves`) or hardcode mock moves per type? (Mock faster, API more accurate)

2. **Health formula:** HP = base_stat from PokeAPI? Or fixed 100? (PokeAPI stats more interesting but varies widely)

3. **Damage formula:** Fixed damage? Type effectiveness? Random variance? (Type effectiveness adds depth)

4. **Can player switch Pokémon mid-battle?** Yes/No?

5. **Single battle or best-of-3?** (Single is simpler)

---

**Next action:** I can write the migration spec (RSpec) if you approve the data model. Say "yes" and I'll draft the migration.
