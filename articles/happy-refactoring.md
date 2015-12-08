# Why does this refactoring make me so happy?

Before: 

```ruby
class Requirement
  def root_rules
    rules.map { |rule| rule.child? ? rule.parent : rule }
  end
end
```

After:

```ruby
class Requirement
  def root_rules
    rules.map(&:root)
  end
end

class Rule
  def root
    child? ? parent : self
  end
end
```

