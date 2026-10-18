# frozen_string_literal: true
#
# === Problem 10 (HARD) — Mini Interpreter ===
#
# A tree-walking interpreter for a tiny language:
#   - integers, variables, let bindings
#   - + - * / and comparisons < > <= >= == !=
#   - if (cond) { ... } else { ... }
#   - fn(params) { ... } closures, called as name(args)
#   - ( expr ) grouping
#
# A program is a sequence of statements; the value of the program is the value
# of the last expression. `let` defines a variable in the CURRENT scope.
#
# The code below is BROKEN. Fix it so every assertion passes.
#
# Run:  ruby 10_interpreter.rb   -> must print  10 OK ✓
#
class Interpreter
  class Error < StandardError; end

  def initialize(src)
    @src = src
  end

  def eval
    ast = Parser.new(tokenize(@src)).parse_program
    eval_block(ast, Environment.new(nil))
  end

  def tokenize(src)
    tokens = []
    i = 0
    n = src.length
    while i < n
      c = src[i]
      if c =~ /\s/
        i += 1
        next
      end
      two = src[i, 2]
      if %w[== != <= >=].include?(two)
        tokens << [:op, two]; i += 2; next
      end
      if c =~ /\d/
        m = src[i, n - i].match(/\A\d+/); tokens << [:num, m[0].to_i]; i += m[0].length; next
      end
      if c =~ /[A-Za-z_]/
        m = src[i, n - i].match(/\A[A-Za-z_]\w*/); tokens << [:name, m[0]]; i += m[0].length; next
      end
      if "+-*/(){}=,<>".include?(c)
        tokens << [:op, c]; i += 1; next
      end
      raise Error, "unexpected character: #{c.inspect}"
    end
    tokens
  end

  def eval_block(stmts, env)
    last = nil
    stmts.each do |s|
      last = if s.first == :let
               env.set(s[1], eval_expr(s[2], env)); nil
             else
               eval_expr(s[1], env)
             end
    end
    last
  end

  def eval_expr(n, env)
    case n.first
    when :num then n[1]
    when :var then env.get(n[1])
    when :binop then eval_binop(n[1], n[2], n[3], env)
    when :if then eval_if(n, env)
    when :fn then Closure.new(n[1], n[2], env)
    when :call then eval_call(n, env)
    end
  end

  def eval_binop(op, l, r, env)
    lv = eval_expr(l, env)
    rv = eval_expr(r, env)
    case op
    when "+" then lv + rv
    when "-" then lv - rv
    when "*" then lv * rv
    when "/" then lv / rv                  # BUG: no division-by-zero guard
    when ">" then lv > rv
    when "<" then lv < rv
    when ">=" then lv >= rv
    when "<=" then lv <= rv
    when "==" then lv == rv
    when "!=" then lv != rv
    end
  end

  def eval_if(n, env)
    cond = eval_expr(n[1], env)
    then_val = eval_block(n[2], env)        # BUG: same env -> let leaks out of the if
    else_val = eval_block(n[3], env)        # BUG: always evaluated -> no short-circuit
    cond ? then_val : else_val
  end

  def eval_call(n, env)
    callee = eval_expr(n[1], env)
    args = n[2].map { |a| eval_expr(a, env) }
    raise Error, "not callable" unless callee.is_a?(Closure)
    call_env = Environment.new(callee.env)
    callee.params.each { |p| call_env.set(p, args.last) } # BUG: every param bound to the last arg
    eval_block(callee.body, call_env)
  end
end

class Parser
  def initialize(tokens)
    @tokens = tokens
    @pos = 0
  end

  def peek; @tokens[@pos]; end
  def at_end?; @pos >= @tokens.length; end
  def peek_op?(ops); t = peek; t && t[0] == :op && ops.include?(t[1]); end
  def peek_name?(name); t = peek; t && t[0] == :name && t[1] == name; end
  def advance; t = @tokens[@pos]; @pos += 1; t; end
  def expect_op(op); t = advance; raise Interpreter::Error, "expected '#{op}', got #{t.inspect}" unless t && t[0] == :op && t[1] == op; end
  def expect_name(name); t = advance; raise Interpreter::Error, "expected '#{name}'" unless t && t[0] == :name && t[1] == name; end

  def parse_program; parse_statements(nil); end

  def parse_statements(stop_op)
    stmts = []
    until at_end? || (stop_op && peek_op?([stop_op]))
      stmts << parse_stmt
    end
    stmts
  end

  def parse_stmt
    if peek_name?("let")
      advance
      name = advance[1]
      expect_op("=")
      [:let, name, parse_expr]
    else
      [:expr, parse_expr]
    end
  end

  def parse_expr
    return parse_if if peek_name?("if")
    return parse_fn if peek_name?("fn")
    parse_comparison
  end

  def parse_if
    expect_name("if"); expect_op("("); cond = parse_expr; expect_op(")")
    expect_op("{"); then_b = parse_statements("}"); expect_op("}")
    expect_name("else"); expect_op("{"); else_b = parse_statements("}"); expect_op("}")
    [:if, cond, then_b, else_b]
  end

  def parse_fn
    expect_name("fn"); expect_op("(")
    params = []
    unless peek_op?([")"])
      params << advance[1]
      while peek_op?([","]); advance; params << advance[1]; end
    end
    expect_op(")"); expect_op("{"); body = parse_statements("}"); expect_op("}")
    [:fn, params, body]
  end

  # BUG: precedence is wrong -- additive is parsed deeper than multiplicative,
  # so "+" binds tighter than "*".
  def parse_comparison
    left = parse_multiplicative
    while peek_op?(%w[< > <= >= == !=])
      op = advance[1]; right = parse_multiplicative; left = [:binop, op, left, right]
    end
    left
  end

  def parse_multiplicative
    left = parse_additive
    while peek_op?(%w[* /])
      op = advance[1]; right = parse_additive; left = [:binop, op, left, right]
    end
    left
  end

  def parse_additive
    left = parse_primary
    while peek_op?(%w[+ -])
      op = advance[1]; right = parse_primary; left = [:binop, op, left, right]
    end
    left
  end

  def parse_primary
    t = advance
    raise Interpreter::Error, "unexpected end of input" unless t
    if t[0] == :num
      [:num, t[1]]
    elsif t[0] == :name
      name = t[1]
      if peek_op?(["("])
        advance
        args = []
        unless peek_op?([")"])
          args << parse_expr
          while peek_op?([","]); advance; args << parse_expr; end
        end
        expect_op(")")
        [:call, [:var, name], args]
      else
        [:var, name]
      end
    elsif t[0] == :op && t[1] == "("
      e = parse_expr; expect_op(")"); e
    else
      raise Interpreter::Error, "unexpected token #{t.inspect}"
    end
  end
end


class Closure
  attr_reader :params, :body, :env
  def initialize(params, body, env); @params = params; @body = body; @env = env; end
end

class Environment
  def initialize(parent); @parent = parent; @vars = {}; end
  def get(name)
    return @vars[name] if @vars.key?(name)
    return @parent.get(name) if @parent
    raise Interpreter::Error, "undefined variable: #{name}"
  end
  def set(name, val); @vars[name] = val; end
end

# ---- DO NOT EDIT BELOW THIS LINE ----
failures = []

def _check(name, failures)
  yield
rescue => e
  failures << "#{name}: #{e.class} - #{e.message}"
end

def _expect_error(name, failures)
  yield
  failures << "#{name}: expected Interpreter::Error but nothing was raised"
rescue Interpreter::Error
  # expected
rescue => e
  failures << "#{name}: expected Interpreter::Error, got #{e.class} - #{e.message}"
end

def run(src); Interpreter.new(src).eval; end

_check("addition", failures) { raise "got #{run("2 + 3")}" unless run("2 + 3") == 5 }
_check("multiplication", failures) { raise "got #{run("2 * 3")}" unless run("2 * 3") == 6 }
_check("parentheses", failures) { raise "got #{run("(1 + 2) * 3")}" unless run("(1 + 2) * 3") == 9 }
_check("left-assoc subtraction", failures) { raise "got #{run("10 - 3 - 2")}" unless run("10 - 3 - 2") == 5 }
_check("operator precedence", failures) { raise "got #{run("1 + 2 * 3")}" unless run("1 + 2 * 3") == 7 }
_check("comparison true", failures) { raise "got #{run("3 > 2")}" unless run("3 > 2") == true }
_check("equality", failures) { raise "got #{run("3 == 3")}" unless run("3 == 3") == true }
_check("let binding", failures) { raise "got #{run("let x = 10\nx + 5")}" unless run("let x = 10\nx + 5") == 15 }
_check("if true branch", failures) { raise "got #{run("if (1 > 0) { 10 } else { 20 }")}" unless run("if (1 > 0) { 10 } else { 20 }") == 10 }
_check("if false branch", failures) { raise "got #{run("if (1 < 0) { 10 } else { 20 }")}" unless run("if (1 < 0) { 10 } else { 20 }") == 20 }
_check("if short-circuits (else not evaluated)", failures) { raise "got #{run("if (1 > 0) { 10 } else { 1 / 0 }")}" unless run("if (1 > 0) { 10 } else { 1 / 0 }") == 10 }
_check("closures capture environment", failures) { raise "got #{run("let make = fn(x) { fn(y) { x + y } }\nlet add5 = make(5)\nadd5(10)")}" unless run("let make = fn(x) { fn(y) { x + y } }\nlet add5 = make(5)\nadd5(10)") == 15 }
_check("function arguments bind in order", failures) { raise "got #{run("let add = fn(a, b) { a + b }\nadd(2, 3)")}" unless run("let add = fn(a, b) { a + b }\nadd(2, 3)") == 5 }
_check("division by zero raises Interpreter::Error", failures) { _expect_error("div0", failures) { run("5 / 0") } }
_check("let inside if does not leak to outer scope", failures) { _expect_error("scope", failures) { run("if (1 > 0) { let y = 99 } else { 0 }\ny") } }

if failures.empty?
  puts "10 OK \u2713"
else
  warn "10 FAILED (#{failures.size}):"
  failures.each { |f| warn "  - #{f}" }
  exit 1
end

