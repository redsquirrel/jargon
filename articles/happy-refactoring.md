# Why does this refactoring make me so happy?

Before: 

```ruby
class Requirement
  has_many :rules

  def root_rules
    rules.map { |rule| rule.child? ? rule.parent : rule }
  end
end
```

After:

```ruby
class Requirement
  has_many :rules

  def root_rules
    rules.map(&:root)
  end
end

class Rule
  belongs_to :parent, class_name: "Rule", foreign_key: :parent_id

  def root
    child? ? parent : self
  end

  def child?
    parent.present?
  end
end
```

