# frozen_string_literal: true
#
# === Problem 07 (MIDDLE) — Declarative State Machine ===
#
# A state-machine mixin built with a DSL, then driven on Order. Fix it so every
# assertion passes. NO ActiveSupport -- pure Ruby (note the `self.included`
# hook instead of `ActiveSupport::Concern`).
#
# DSL (see Order below):
#   state_machine do
#     state :cart, initial: true
#     state :checkout, :paid, :shipped, :cancelled
#     event :checkout! do
#       transition from: :cart, to: :checkout
#     end
#     event :pay! do
#       transition from: :checkout, to: :paid, guard: :payable?
#     end
#     event :cancel! do
#       transition from: [:cart, :checkout], to: :cancelled
#     end
#   end
#
# Contract:
#   - `state` returns the current state; a fresh object starts at the initial.
#   - `event!` fires the matching transition and updates `state`.
#   - `from:` may be a single Symbol OR an Array of Symbols.
#   - `guard:` is a method name; if it returns falsy the transition cannot fire.
#   - If NO transition can fire (wrong `from` OR failed guard), `event!` raises
#     StateMachine::InvalidTransition.
#   - `can_event?` (e.g. `can_checkout?`, `can_pay?`) returns whether the event
#     can fire right now, considering `from` AND the guard. Must NOT raise.
#
# Run:  ruby 07_state_machine.rb   -> must print  07 OK ✓
#
module StateMachine
  class InvalidTransition < StandardError; end

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def state_machine(&block)
      @_states = []
      @_events = {}
      @_initial_state = nil
      instance_eval(&block)

      define_method(:state) { @_state } # BUG: never seeds the initial state

      @_events.each do |name, transitions|
        define_method(name) { _fire(name, transitions) }
        define_method("can_#{name.to_s.chomp('!')}?") { _can_fire?(transitions) }
      end
    end

    def state(*names, initial: nil)
      names.each { |n| @_states << n }
      @_initial_state = names.first if initial
    end

    def event(name, &block)
      transitions = []
      builder = TransitionBuilder.new(transitions)
      builder.instance_eval(&block)
      @_events[name] = transitions
    end
  end

  class TransitionBuilder
    def initialize(transitions); @transitions = transitions; end

    def transition(from:, to:, guard: nil)
      @transitions << { from: from, to: to, guard: guard }
    end
  end

  def _can_fire?(transitions)
    transitions.any? { |t| t[:from] == @_state } # BUG: Array == Symbol; guard ignored
  end

  def _fire(name, transitions)
    t = transitions.find { |tr| tr[:from] == @_state } # BUG: Array == Symbol; guard ignored
    return unless t                                       # BUG: silent no-op instead of raising
    @_state = t[:to]
  end
end

class Order
  include StateMachine

  state_machine do
    state :cart, initial: true
    state :checkout, :paid, :shipped, :cancelled

    event :checkout! do
      transition from: :cart, to: :checkout
    end

    event :pay! do
      transition from: :checkout, to: :paid, guard: :payable?
    end

    event :ship! do
      transition from: :paid, to: :shipped
    end

    event :cancel! do
      transition from: [:cart, :checkout], to: :cancelled
    end
  end

  attr_accessor :total

  def initialize(total: nil)
    @total = total
  end

  def payable?
    total.to_f > 0
  end
end

# ---- DO NOT EDIT BELOW THIS LINE ----
failures = []

def _check(name, failures)
  yield
rescue => e
  failures << "#{name}: #{e.class} - #{e.message}"
end

def _expect_invalid(failures, name)
  yield
rescue StateMachine::InvalidTransition
  # expected
rescue => e
  failures << "#{name}: expected InvalidTransition, got #{e.class} - #{e.message}"
else
  failures << "#{name}: expected InvalidTransition, but nothing was raised"
end

_check("fresh order starts at :cart", failures) { raise "got #{Order.new.state.inspect}" unless Order.new.state == :cart }
_check("can_checkout? from cart", failures) { raise "got #{Order.new.can_checkout?}" unless Order.new.can_checkout? == true }
_check("checkout! moves to :checkout", failures) { o = Order.new; o.checkout!; raise "got #{o.state.inspect}" unless o.state == :checkout }
_check("can_checkout? false from checkout", failures) { o = Order.new; o.checkout!; raise "got #{o.can_checkout?}" unless o.can_checkout? == false }

_expect_invalid(failures, "ship! from cart raises") { Order.new.ship! }

_check("pay! when payable moves to :paid", failures) { o = Order.new(total: 100); o.checkout!; o.pay!; raise "got #{o.state.inspect}" unless o.state == :paid }
_expect_invalid(failures, "pay! when NOT payable raises") { o = Order.new(total: 0); o.checkout!; o.pay! }
_check("can_pay? false when not payable (after checkout)", failures) { o = Order.new(total: 0); o.checkout!; raise "got #{o.can_pay?}" unless o.can_pay? == false }
_check("can_pay? true when payable (after checkout)", failures) { o = Order.new(total: 100); o.checkout!; raise "got #{o.can_pay?}" unless o.can_pay? == true }

_check("cancel! from checkout (array from)", failures) { o = Order.new; o.checkout!; o.cancel!; raise "got #{o.state.inspect}" unless o.state == :cancelled }
_check("cancel! from cart (array from)", failures) { o = Order.new; o.cancel!; raise "got #{o.state.inspect}" unless o.state == :cancelled }
_check("can_cancel? from cart", failures) { raise "got #{Order.new.can_cancel?}" unless Order.new.can_cancel? == true }
_expect_invalid(failures, "ship! from cancelled raises") { o = Order.new; o.cancel!; o.ship! }

if failures.empty?
  puts "07 OK \u2713"
else
  warn "07 FAILED (#{failures.size}):"
  failures.each { |f| warn "  - #{f}" }
  exit 1
end
