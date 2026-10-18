# frozen_string_literal: true
#
# === Problem 08 (HARD) — Mini Template Engine ===
#
# A tiny template engine. Fix it so every assertion passes.
#
# Supported syntax:
#   {{ var }}              interpolation (with or without spaces inside braces)
#   {{ a.b.c }}            nested lookup (dig) into Hash/struct context values
#   {% if cond %}A{% else %}B{% endif %}   conditional (else optional)
#   {% if x == "admin" %}  equality test against a string literal
#   {% for x in items %}...{% endfor %}    loop; `x` is bound per iteration and
#                                         MUST NOT leak after the loop
#
# Nested blocks (for inside if, if inside for, for inside for) must work, and
# SIBLING loops in the same template must each render independently.
#
# The code below is a naive regex renderer and is BROKEN in several ways.
#
# Run:  ruby 08_template_engine.rb   -> must print  08 OK ✓
#
class Template
  def initialize(source)
    @source = source
  end

  def render(context)
    context = context.transform_keys(&:to_s)
    _render(@source, context)
  end

  def _render(text, context)
    text = _render_fors(text, context)
    text = _render_ifs(text, context)
    _interpolate(text, context)
  end

  def _render_fors(text, context)
    text.gsub(/{% for (\w+) in (\w+) %}(.*){% endfor %}/m) do # BUG: greedy .* mis-pairs sibling loops
      var, coll, body = $1, $2, $3
      Array(context.fetch(coll, [])).map do |item|
        context[var] = item                                     # BUG: leaks loop var into outer context
        _render(body, context)
      end.join
    end
  end

  def _render_ifs(text, context)
    text = text.gsub(/{% if (.+?) %}(.*?){% else %}(.*?){% endif %}/m) { _truthy?($1, context) ? $2 : $3 }
    text.gsub(/{% if (.+?) %}(.*?){% endif %}/m) { _truthy?($1, context) ? $2 : "" }
  end

  def _truthy?(cond, context)
    context.fetch(cond.strip, nil) # BUG: no == operator; the whole condition is used as a key
  end

  def _interpolate(text, context)
    text.gsub(/{{ (\w+) }}/) { context.fetch($1, "").to_s } # BUG: requires spaces; no dot/dig support
  end
end

# ---- DO NOT EDIT BELOW THIS LINE ----
failures = []

def _check(name, failures)
  yield
rescue => e
  failures << "#{name}: #{e.class} - #{e.message}"
end

def render(src, ctx)
  Template.new(src).render(ctx)
end

_check("basic interpolation (spaces)", failures) { raise "got #{render("Hi {{ name }}!", { name: "Ada" }).inspect}" unless render("Hi {{ name }}!", { name: "Ada" }) == "Hi Ada!" }
_check("interpolation without spaces", failures) { raise "got #{render("{{name}}", { name: "Cy" }).inspect}" unless render("{{name}}", { name: "Cy" }) == "Cy" }
_check("nested dig", failures) { raise "got #{render("{{ user.name }}", { user: { name: "Bo" } }).inspect}" unless render("{{ user.name }}", { user: { name: "Bo" } }) == "Bo" }
_check("if truthy", failures) { raise "got #{render("{% if show %}Y{% else %}N{% endif %}", { show: true }).inspect}" unless render("{% if show %}Y{% else %}N{% endif %}", { show: true }) == "Y" }
_check("if falsey", failures) { raise "got #{render("{% if show %}Y{% else %}N{% endif %}", { show: false }).inspect}" unless render("{% if show %}Y{% else %}N{% endif %}", { show: false }) == "N" }
_check("if == true branch", failures) { raise "got #{render('{% if role == "admin" %}A{% else %}U{% endif %}', { role: "admin" }).inspect}" unless render('{% if role == "admin" %}A{% else %}U{% endif %}', { role: "admin" }) == "A" }
_check("if == false branch", failures) { raise "got #{render('{% if role == "admin" %}A{% else %}U{% endif %}', { role: "user" }).inspect}" unless render('{% if role == "admin" %}A{% else %}U{% endif %}', { role: "user" }) == "U" }
_check("for basic", failures) { raise "got #{render("{% for x in xs %}{{ x }}{% endfor %}", { xs: [1, 2, 3] }).inspect}" unless render("{% for x in xs %}{{ x }}{% endfor %}", { xs: [1, 2, 3] }) == "123" }
_check("for with surrounding text", failures) { raise "got #{render("{% for x in xs %}[{{ x }}]{% endfor %}", { xs: [1, 2, 3] }).inspect}" unless render("{% for x in xs %}[{{ x }}]{% endfor %}", { xs: [1, 2, 3] }) == "[1][2][3]" }
_check("loop var does not leak", failures) { raise "got #{render("{% for x in xs %}{{ x }}{% endfor %}{{ x }}", { xs: [1, 2, 3] }).inspect}" unless render("{% for x in xs %}{{ x }}{% endfor %}{{ x }}", { xs: [1, 2, 3] }) == "123" }
_check("nested for", failures) { raise "got #{render("{% for a in as %}{% for b in bs %}{{ a }}{{ b }}{% endfor %}{% endfor %}", { as: %w[x y], bs: %w[1 2] }).inspect}" unless render("{% for a in as %}{% for b in bs %}{{ a }}{{ b }}{% endfor %}{% endfor %}", { as: %w[x y], bs: %w[1 2] }) == "x1x2y1y2" }
_check("sibling loops", failures) { raise "got #{render("{% for a in as %}A{% endfor %}{% for b in bs %}B{% endfor %}", { as: %w[x y], bs: %w[1 2] }).inspect}" unless render("{% for a in as %}A{% endfor %}{% for b in bs %}B{% endfor %}", { as: %w[x y], bs: %w[1 2] }) == "AABB" }

if failures.empty?
  puts "08 OK \u2713"
else
  warn "08 FAILED (#{failures.size}):"
  failures.each { |f| warn "  - #{f}" }
  exit 1
end
