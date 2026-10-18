# frozen_string_literal: true
#
# === Problem 03 (MIDDLE) — Composable Pipeline ===
#
# A composable, LAZY data pipeline:
#
#   Pipeline.new { [1,2,3,4] }.map { |x| x * 2 }.select { |x| x > 4 }.run
#   # => [6, 8]
#
# The producer block returns anything that responds to `each` (Array, Range,
# Enumerator...). Steps compose and are evaluated LAZILY, so an (effectively)
# infinite producer plus `take(n)` must only pull ~n elements, not the lot.
#
# Contract `run` enforces:
#   - If the pipeline ends with `reduce`, `run` returns the reduced scalar.
#   - Otherwise `run` returns an Array.
#   - `reduce`'s block is called as block.call(accumulator, element).
#
# The code below is BROKEN. Fix it so every assertion passes.
#
# Run:  ruby 03_pipeline.rb   -> must print  03 OK ✓
#
class Pipeline
  def initialize(&producer)
    @producer = producer
    @steps = []
  end

  def map(&block)    = (@steps << [:map, block]; self)
  def select(&block) = (@steps << [:select, block]; self)
  def take(n)        = (@steps << [:take, n]; self)
  def reduce(seed, &block) = (@steps << [:reduce, seed, block]; self)

  def run
    result = @producer.call # BUG: never made lazy -> materializes the whole producer

    @steps.each do |step|
      case step.first
      when :map     then result = result.map(&step[1])
      when :select  then result = result.select(&step[1])
      when :take    then result = result.first(step[1])
      when :reduce  then result = result.inject(step[1]) { |acc, x| step[2].call(x, acc) } # BUG: block args swapped
      end
    end

    result
  end
end

# ---- DO NOT EDIT BELOW THIS LINE ----
failures = []

def _check(name, failures)
  yield
rescue => e
  failures << "#{name}: #{e.class} - #{e.message}"
end

_check("map + select (finite)", failures) do
  out = Pipeline.new { [1, 2, 3, 4] }.map { |x| x * 2 }.select { |x| x > 4 }.run
  raise "got #{out.inspect}" unless out == [6, 8]
end

_check("reduce block arg order (non-commutative)", failures) do
  out = Pipeline.new { [1, 2, 3] }.reduce(0) { |acc, x| acc * 10 + x }.run
  raise "got #{out.inspect}" unless out == 123
end

_check("map + select + reduce(sum)", failures) do
  out = Pipeline.new { [1, 2, 3] }.map { |x| x }.select { |x| x > 1 }.reduce(0) { |s, x| s + x }.run
  raise "got #{out.inspect}" unless out == 5
end

_check("chaining returns self (composable)", failures) do
  p = Pipeline.new { [1] }
  raise "not composable" unless p.map { |x| x }.equal?(p)
end

pulled = 0
infinite = Pipeline.new do
  Enumerator.new do |y|
    x = 0
    loop do
      x += 1
      break if x > 1_000_000 # hard cap so an eager bug can't hang the process
      pulled += 1
      y << x
    end
  end
end

_check("lazy: take(3) pulls only a few", failures) do
  out = infinite.map { |n| n }.take(3).run
  raise "pulled #{pulled} elements (expected lazy)" unless pulled <= 4
end

_check("lazy: take(3) result", failures) do
  pulled = 0 # reset local view; the shared counter is what the previous check read
  out = Pipeline.new { (1..1_000_000).lazy }.take(3).run
  raise "got #{out.inspect}" unless out == [1, 2, 3]
end

if failures.empty?
  puts "03 OK \u2713"
else
  warn "03 FAILED (#{failures.size}):"
  failures.each { |f| warn "  - #{f}" }
  exit 1
end
