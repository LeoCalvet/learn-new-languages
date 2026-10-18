# frozen_string_literal: true
#
# === Problem 06 (MIDDLE) — Method-Missing Proxy ===
#
# A LoggingProxy wraps any object, records every forwarded call name in
# `calls`, and forwards the call (arguments AND block) to the wrapped target.
# Fix it so every assertion passes.
#
# Contract:
#   - Methods not defined on the proxy itself are forwarded to the target.
#   - Arguments forwarded correctly (0, 1, many).
#   - Blocks forwarded.
#   - `respond_to?(:foo)` is truthful about the target (respond_to_missing?).
#   - Calling a method the TARGET does not have must raise NoMethodError
#     (do NOT swallow it).
#
# Run:  ruby 06_method_missing_proxy.rb   -> must print  06 OK ✓
#
class LoggingProxy
  attr_reader :target, :calls

  def initialize(target)
    @target = target
    @calls = []
  end

  def method_missing(name, *args, &block)
    @calls << name
    @target.send(name, args) # BUG: args passed as ONE array (no splat); block dropped
  end
  # BUG: no respond_to_missing? -> respond_to? lies about target methods
end

# ---- DO NOT EDIT BELOW THIS LINE ----
failures = []

def _check(name, failures)
  yield
rescue => e
  failures << "#{name}: #{e.class} - #{e.message}"
end

proxy = LoggingProxy.new("hello")

_check("forwards 0-arg method", failures) { raise "got #{proxy.upcase.inspect}" unless proxy.upcase == "HELLO" }
_check("forwards multi-arg method", failures) { raise "got #{proxy.gsub(/l/, "L").inspect}" unless proxy.gsub(/l/, "L") == "heLLo" }
_check("records forwarded calls", failures) do
  fresh = LoggingProxy.new("hi")
  fresh.upcase
  raise "got #{fresh.calls.inspect}" unless fresh.calls == [:upcase]
end
_check("forwards block (each)", failures) do
  out = []
  LoggingProxy.new([1, 2, 3]).each { |x| out << x }
  raise "got #{out.inspect}" unless out == [1, 2, 3]
end
_check("forwards block (map)", failures) { raise "got #{LoggingProxy.new([1, 2, 3]).map { |x| x * 2 }.inspect}" unless LoggingProxy.new([1, 2, 3]).map { |x| x * 2 } == [2, 4, 6] }
_check("respond_to? truthy for target method", failures) { raise "got #{proxy.respond_to?(:upcase).inspect}" unless proxy.respond_to?(:upcase) == true }
_check("respond_to? falsey for unknown", failures) { raise "got #{proxy.respond_to?(:nope).inspect}" unless proxy.respond_to?(:nope) == false }
_check("unknown method raises NoMethodError", failures) do
  begin
    proxy.nonexistent_method_xyz
    raise "should have raised NoMethodError"
  rescue NoMethodError
    # expected
  end
end

if failures.empty?
  puts "06 OK \u2713"
else
  warn "06 FAILED (#{failures.size}):"
  failures.each { |f| warn "  - #{f}" }
  exit 1
end
