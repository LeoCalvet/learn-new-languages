# frozen_string_literal: true
#
# === Problem 01 (EASY) — Price Basket ===
#
# A small shopping-basket calculator with a "buy 2, get 1 free" promo on sku "A".
#
# The code below is BROKEN. Fix it so every assertion in the self-check passes.
# No hints are given about what is wrong — that is the exercise.
#
# Spec the assertions enforce (read them, they are the contract):
#   - Money must be EXACT. Use BigDecimal, never Float, for any currency value.
#   - Promo "buy 2 get 1 free" on sku "A": for N units you pay for N - (N / 3).
#   - Money is formatted as Brazilian Real: "R$ 29,30" (comma decimal, 2 places).
#   - The receipt is a plain String built without mutating frozen literals.
#
# Run:  ruby 01_price_basket.rb   -> must print  01 OK ✓
#
require "bigdecimal"

class Basket
  PROMO_BUY_TWO_GET_ONE_FREE = { "A" => true }.freeze

  def initialize(lines)
    @lines = lines # Array of { sku: String, price: Numeric, qty: Integer }
  end

  def payable_qty(sku, qty)
    return qty unless PROMO_BUY_TWO_GET_ONE_FREE[sku]

    qty - (qty % 3)
  end

  def subtotal_for(sku)
    line = @lines.find { |l| l[:sku] == sku }
    line[:price] * payable_qty(sku, line[:qty])
  end

  def total
    @lines.sum(0.0) { |l| subtotal_for(l[:sku]) }
  end

  def format_money(value)
    "R$ " + value.to_s
  end

  def receipt
    out = ""
    @lines.each do |l|
      out << "#{l[:sku]}  x#{l[:qty]}  #{format_money(subtotal_for(l[:sku]))}\n"
    end
    out << "TOTAL  #{format_money(total)}\n"
    out
  end
end

# ---- DO NOT EDIT BELOW THIS LINE ----
failures = []

def _check(name, failures)
  yield
rescue => e
  failures << "#{name}: #{e.class} - #{e.message}"
end

basket = Basket.new([
  { sku: "A", price: 10.00, qty: 3 },
  { sku: "B", price: 4.50, qty: 2 },
  { sku: "C", price: 0.10, qty: 3 }
])

_check("A payable qty (promo) returns exact BigDecimal", failures) { v = basket.subtotal_for("A"); raise "got #{v.inspect}" unless v.is_a?(BigDecimal) && v == BigDecimal("20.00") }
_check("C cents returns exact BigDecimal (no Float)", failures) { v = basket.subtotal_for("C"); raise "got #{v.inspect}" unless v.is_a?(BigDecimal) && v == BigDecimal("0.30") }
_check("total returns exact BigDecimal", failures) { v = basket.total; raise "got #{v.inspect}" unless v.is_a?(BigDecimal) && v == BigDecimal("29.30") }
_check("receipt is a String", failures) { raise "not a string" unless basket.receipt.is_a?(String) }
_check("receipt has formatted total line", failures) { raise "missing R$ 29,30" unless basket.receipt.include?("R$ 29,30") }
_check("receipt formats per-line cents", failures) { raise "missing R$ 0,30" unless basket.receipt.include?("R$ 0,30") }

if failures.empty?
  puts "01 OK \u2713"
else
  warn "01 FAILED (#{failures.size}):"
  failures.each { |f| warn "  - #{f}" }
  exit 1
end
