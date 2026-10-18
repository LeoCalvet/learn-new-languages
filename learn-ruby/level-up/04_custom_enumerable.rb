# frozen_string_literal: true
#
# === Problem 04 (MIDDLE) — Custom Enumerable (Linked List) ===
#
# A singly linked list that includes Enumerable. Fix it so every assertion
# passes.
#
# The Enumerable contract: `each` must yield values in INSERTION order and must
# return an Enumerator (via `enum_for(:each)`) when called without a block.
# Once `each` is correct, map/select/reduce/min/max/count come for free. The
# methods overridden below (`size`, `include?`) are also broken.
#
# Run:  ruby 04_custom_enumerable.rb   -> must print  04 OK ✓
#
class LinkedList
  include Enumerable

  Node = Struct.new(:value, :next)

  attr_reader :head

  def initialize(*values)
    @head = nil
    values.reverse_each { |v| prepend(v) }
  end

  def prepend(value)
    @head = Node.new(value, @head)
  end

  def each
    node = @head
    collected = []
    while node
      collected << node.value
      node = node.next
    end

    collected.reverse.each { |v| yield v } # BUG: yields in reverse order

    self                                     # BUG: never returns enum_for when no block given
  end

  def size
    count = 1                                # BUG: off-by-one
    each { |_| count += 1 }
    count
  end

  def include?(value)
    each { |v| return false if v == value }  # BUG: inverted -> returns false when found
    true
  end
end

# ---- DO NOT EDIT BELOW THIS LINE ----
failures = []

def _check(name, failures)
  yield
rescue => e
  failures << "#{name}: #{e.class} - #{e.message}"
end

list = LinkedList.new(1, 2, 3)

_check("to_a preserves insertion order", failures) { raise "got #{list.to_a.inspect}" unless list.to_a == [1, 2, 3] }
_check("each without block returns Enumerator", failures) { raise "got #{list.each.class}" unless list.each.is_a?(Enumerator) }
_check("each enumerator yields in order", failures) { raise "got #{list.each.to_a.inspect}" unless list.each.to_a == [1, 2, 3] }
_check("map", failures) { raise "got #{list.map { |x| x * 10 }.inspect}" unless list.map { |x| x * 10 } == [10, 20, 30] }
_check("select", failures) { raise "got #{list.select { |x| x > 1 }.inspect}" unless list.select { |x| x > 1 } == [2, 3] }
_check("reduce", failures) { raise "got #{list.reduce(0) { |s, x| s + x }.inspect}" unless list.reduce(0) { |s, x| s + x } == 6 }
_check("count from Enumerable", failures) { raise "got #{list.count}" unless list.count == 3 }
_check("size", failures) { raise "got #{list.size}" unless list.size == 3 }
_check("size of empty list", failures) { raise "got #{LinkedList.new.size}" unless LinkedList.new.size == 0 }
_check("include? present", failures) { raise "got #{list.include?(2)}" unless list.include?(2) == true }
_check("include? absent", failures) { raise "got #{list.include?(9)}" unless list.include?(9) == false }
_check("min", failures) { raise "got #{list.min}" unless list.min == 1 }
_check("max", failures) { raise "got #{list.max}" unless list.max == 3 }

if failures.empty?
  puts "04 OK \u2713"
else
  warn "04 FAILED (#{failures.size}):"
  failures.each { |f| warn "  - #{f}" }
  exit 1
end
