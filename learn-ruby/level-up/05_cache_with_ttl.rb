# frozen_string_literal: true
#
# === Problem 05 (MIDDLE) — TTL Cache ===
#
# A key/value cache where entries expire after `ttl` seconds. Fix it so every
# assertion passes.
#
# Contract:
#   - fetch(key) { compute } stores compute's result and returns it. On a FRESH
#     hit it returns the cached value WITHOUT calling the block.
#   - fetch(key) with no block returns the currently cached value, or nil.
#   - An entry is fresh while clock < created_at + ttl. Once expired, the next
#     fetch(key) { ... } recomputes.
#   - Time comes from an injected `clock:` callable (returns a Numeric or
#     Time). Do NOT call Time.now directly -- the tests advance the clock.
#   - Callers must NOT be able to mutate the cached value: return a defensive
#     copy OR freeze stored values, so a caller mutating its returned object
#     cannot corrupt the cache.
#   - Must be thread-safe. I will review your locking at review time; the
#     self-check does not test concurrency.
#
# Run:  ruby 05_cache_with_ttl.rb   -> must print  05 OK ✓
#
class Cache
  def initialize(ttl:, clock: -> { Time.now })
    @ttl = ttl
    @clock = clock
    @store = {}
    @expiry = {}
    @mutex = Mutex.new
  end

  def fetch(key, &block)
    value = @store[key]

    if value && fresh?(key)
      block.call(value) if block        # BUG: calls the compute block on a hit
      return value                       # BUG: returns the live cached object (no defensive copy)
    end

    return value unless block

    computed = block.call
    @store[key] = computed               # BUG: stores the live object (no freeze / no copy)
    @expiry[key] = @clock.call + @ttl
    computed
  end

  def fresh?(key)
    @expiry[key] <= @clock.call          # BUG: inverted -> treats expired entries as fresh
  end

  def delete(key)
    @store.delete(key)
    @expiry.delete(key)
  end

  def clear
    @store.clear
    @expiry.clear
  end
end

# ---- DO NOT EDIT BELOW THIS LINE ----
failures = []

def _check(name, failures)
  yield
rescue => e
  failures << "#{name}: #{e.class} - #{e.message}"
end

now = 100.0
clock = -> { now }
calls = 0
cache = Cache.new(ttl: 5, clock: clock)

v1 = cache.fetch(:k) { calls += 1; [1, 2, 3] }
_check("first fetch computes once", failures) { raise "calls=#{calls}" unless calls == 1 }
_check("first fetch returns value", failures) { raise "got #{v1.inspect}" unless v1 == [1, 2, 3] }

v2 = cache.fetch(:k) { calls += 1; [9, 9] }
_check("fresh hit does NOT call compute block", failures) { raise "calls=#{calls}" unless calls == 1 }
_check("fresh hit returns cached value", failures) { raise "got #{v2.inspect}" unless v2 == [1, 2, 3] }

now = 110.0
v3 = cache.fetch(:k) { calls += 1; [7, 7] }
_check("expired entry recomputes", failures) { raise "calls=#{calls}" unless calls == 2 }
_check("expired entry returns new value", failures) { raise "got #{v3.inspect}" unless v3 == [7, 7] }

_check("no-block fetch returns current", failures) { raise "got #{cache.fetch(:k).inspect}" unless cache.fetch(:k) == [7, 7] }
_check("no-block fetch of missing returns nil", failures) { raise "got #{cache.fetch(:missing).inspect}" unless cache.fetch(:missing).nil? }

now = 120.0
calls2 = 0
a1 = cache.fetch(:m) { calls2 += 1; [10, 20] }
begin
  a1 << 30
rescue FrozenError
  # freezing the stored value is an acceptable strategy
end
a2 = cache.fetch(:m) { calls2 += 1; [99] }
_check("cache intact after caller mutation", failures) { raise "got #{a2.inspect}" unless a2 == [10, 20] }
_check("no recompute caused by caller mutation", failures) { raise "calls2=#{calls2}" unless calls2 == 1 }

if failures.empty?
  puts "05 OK \u2713"
else
  warn "05 FAILED (#{failures.size}):"
  failures.each { |f| warn "  - #{f}" }
  exit 1
end
