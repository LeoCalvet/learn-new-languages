# frozen_string_literal: true
#
# === Problem 02 (EASY) — Weekly Availability Grid ===
#
# People have a 7-day availability array (index 0 = Monday ... 6 = Sunday).
# The code below is BROKEN. Fix it so every assertion passes.
#
# Spec the assertions enforce:
#   - rotate(n) shifts a person's pattern so the slot at index i moves to
#     index (i + n) % 7  (a right rotation by n days, wrapping around).
#   - available_on(day) returns the people who ARE available that day.
#   - days_with_at_least(k) returns the day indices where AT LEAST k people
#     are available (i.e. count >= k, boundary inclusive).
#
# Run:  ruby 02_availability_grid.rb   -> must print  02 OK ✓
#
class Person
  attr_reader :name, :availability

  def initialize(name, availability) # availability: Array of 7 booleans, index 0 = Monday
    @name = name
    @availability = availability
  end

  def available?(day_index)
    @availability[day_index]
  end

  def rotate(n)
    rotated = Array.new(7, false)

    @availability.each_with_index do |avail, i|
      rotated[(i - n) % 7] = avail
    end

    Person.new(@name, rotated)
  end
end

class AvailabilityGrid
  def initialize(people)
    @people = people
  end

  def available_on(day_index)
    @people.reject { |p| p.available?(day_index) }
  end

  def days_with_at_least(k)
    (0..6).select { |d| @people.count { |p| p.available?(d) } > k }
  end
end

# ---- DO NOT EDIT BELOW THIS LINE ----
failures = []

def _check(name, failures)
  yield
rescue => e
  failures << "#{name}: #{e.class} - #{e.message}"
end

alice = Person.new("alice", [true,  false, false, false, false, false, false]) # only Mon
bob   = Person.new("bob",   [true,  false, true,  false, false, false, false]) # Mon + Wed
carol = Person.new("carol", [false, true,  true,  true,  true,  true,  true])  # every day except Mon
grid  = AvailabilityGrid.new([alice, bob, carol])

_check("rotate(1) moves Mon -> Tue", failures) { raise unless alice.rotate(1).available?(1) == true }
_check("rotate(1) clears Mon", failures) { raise unless alice.rotate(1).available?(0) == false }
_check("rotate(6) moves Mon -> Sun", failures) { raise unless alice.rotate(6).available?(6) == true }
_check("rotate is non-destructive", failures) { raise unless alice.available?(0) == true }
_check("available_on(Mon)", failures) { raise "got #{grid.available_on(0).map(&:name).sort.inspect}" unless grid.available_on(0).map(&:name).sort == ["alice", "bob"] }
_check("available_on(Wed)", failures) { raise "got #{grid.available_on(2).map(&:name).sort.inspect}" unless grid.available_on(2).map(&:name).sort == ["bob", "carol"] }
_check("days_with_at_least(2) boundary inclusive", failures) { raise "got #{grid.days_with_at_least(2).inspect}" unless grid.days_with_at_least(2) == [0, 2] }
_check("days_with_at_least(3) empty", failures) { raise unless grid.days_with_at_least(3) == [] }

if failures.empty?
  puts "02 OK \u2713"
else
  warn "02 FAILED (#{failures.size}):"
  failures.each { |f| warn "  - #{f}" }
  exit 1
end
