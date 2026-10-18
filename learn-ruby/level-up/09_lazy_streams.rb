# frozen_string_literal: true
#
# === Problem 09 (HARD) — Lazy Infinite Streams ===
#
# A functional-style lazy stream: head is a value, tail is a THUNK that produces
# the rest of the stream on demand. Supports infinite streams.
#
# API:
#   Stream.iterate(seed) { |prev| next_value }  # seed, f(seed), f(f(seed)), ...
#   Stream.from_enum(enum)                      # wrap an Enumerator (finite or not)
#   Stream.merge(a, b)                          # merge two ASCENDING streams into one ascending
#   stream.head / stream.tail                   # tail forces the thunk (and MUST memoize)
#   stream.take(n)                              # first n as an Array
#   stream.map { |x| }                          # lazy map
#   stream.select { |x| }                       # lazy select (works on infinite streams)
#   stream.take_while { |x| }                   # take while predicate true (excludes first false)
#
# The code below is BROKEN. Fix it so every assertion passes. None of the
# self-check streams are truly unbounded, so an eager bug fails the laziness
# check instead of hanging the process.
#
# Run:  ruby 09_lazy_streams.rb   -> must print  09 OK ✓
#
class Stream
  class Empty
    def empty? = true
    def head = raise "empty stream"
    def tail = self
    def take(_n) = []
    def map = self
    def select = self
    def take_while = []
  end

  def self.empty = (@empty_instance ||= Empty.new)

  def initialize(head, &tail)
    @head = head
    @tail = tail
  end

  def head = @head
  def empty? = false

  def tail
    @rest = @tail.call        # BUG: not memoized -> recomputes the thunk on every call
    @rest
  end

  def take(n)
    return [] if n <= 0
    [head] + tail.take(n - 1)
  end

  def map(&f)
    rest = tail.map(&f)        # BUG: forces the tail eagerly (not lazy)
    Stream.new(f.call(head)) { rest }
  end

  def select(&f)
    return tail.select(&f) unless f.call(head)
    Stream.new(head) { tail.select(&f) }
  end

  def take_while(&p)
    result = [head]            # BUG: includes head unconditionally (off-by-one)
    result += tail.take_while(&p) if p.call(head)
    result
  end

  def self.iterate(seed, &f)
    Stream.new(seed) { iterate(f.call(seed), &f) }
  end

  def self.from_enum(enum)
    Stream.new(enum.next) { from_enum(enum) }
  rescue StopIteration
    empty
  end

  def self.merge(a, b)
    return b if a.empty?
    return a if b.empty?
    if a.head <= b.head
      Stream.new(a.head) { merge(a, b.tail) } # BUG: advanced b instead of a
    else
      Stream.new(b.head) { merge(a.tail, b) } # BUG: advanced a instead of b
    end
  end
end

# ---- DO NOT EDIT BELOW THIS LINE ----
failures = []

def _check(name, failures)
  yield
rescue => e
  failures << "#{name}: #{e.class} - #{e.message}"
end

nats = Stream.iterate(1) { |x| x + 1 }

_check("head", failures) { raise "got #{nats.head}" unless nats.head == 1 }
_check("take(5)", failures) { raise "got #{nats.take(5).inspect}" unless nats.take(5) == [1, 2, 3, 4, 5] }
_check("select is lazy on infinite stream", failures) { raise "got #{nats.select(&:even?).take(3).inspect}" unless nats.select(&:even?).take(3) == [2, 4, 6] }

pulled = 0
enum = Enumerator.new { |y| x = 0; loop { break if x >= 10_000; x += 1; pulled += 1; y << x } }
mapped = Stream.from_enum(enum).map { |n| n * 10 }
res = mapped.take(3)
_check("map is lazy (pulls only a few)", failures) { raise "pulled #{pulled}" unless pulled <= 4 }
_check("map take(3) result", failures) { raise "got #{res.inspect}" unless res == [10, 20, 30] }

_check("take_while excludes first failing element", failures) { raise "got #{nats.take_while { |x| x < 4 }.inspect}" unless nats.take_while { |x| x < 4 } == [1, 2, 3] }
_check("take_while empty when predicate fails immediately", failures) { raise "got #{nats.take_while { |x| x > 100 }.inspect}" unless nats.take_while { |x| x > 100 } == [] }

f_count = 0
memo_stream = Stream.iterate(1) { |x| f_count += 1; x + 1 }
memo_stream.take(5)
memo_stream.take(5)
_check("tail is memoized (second traversal does not recompute)", failures) { raise "f_count=#{f_count}" unless f_count == 5 }

odds_from_1 = Stream.iterate(1) { |x| x + 2 }   # 1, 3, 5, 7, ...
evens_from_2 = Stream.iterate(2) { |x| x + 2 }  # 2, 4, 6, 8, ...
_check("merge two ascending streams", failures) { raise "got #{Stream.merge(odds_from_1, evens_from_2).take(6).inspect}" unless Stream.merge(odds_from_1, evens_from_2).take(6) == [1, 2, 3, 4, 5, 6] }

if failures.empty?
  puts "09 OK \u2713"
else
  warn "09 FAILED (#{failures.size}):"
  failures.each { |f| warn "  - #{f}" }
  exit 1
end
