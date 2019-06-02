class AssertionFailed < Exception
end

# If `cond` is `false`, raise `exc`.
#
# If `exc` is not provided, `AssertionFailed` will be raised instead with information about the faulty expression.
# If the expression is a comparison, the result of each side of the comparison will also be shown.
macro assert(cond, exc = nil)
  unless {{ cond }}
    {% if exc %}
      raise {{ exc }}
    {% else %}
      {% if cond.is_a? Call && %w(== != < > <= >=).any? { |s| s == cond.name.stringify } %}
        {% a = cond.receiver; b = cond.args[0] %}
        %error = "#{{{ a.stringify }}} => #{{{ a }}} {{ cond.name }} #{{{ b }}} <= #{{{ b.stringify }}}"
      {% else %}
        %error = {{ cond.stringify }}
      {% end %}
      raise AssertionFailed.new(%error)
    {% end %}
  end
end

# Assert only in debug mode
macro debug_assert(cond, exc = nil)
  {% unless flag? :release %}
    assert({{ cond }}, {{ exc }})
  {% end %}
end
