# RuleRover

Experimental library implementing some of the core logic programming algorithms. The library provides a simple DSL for creating a knowledge base in propositional and first-order logic.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rule_rover'
```

And then execute:

```sh
$ bundle install
```

Or install it yourself as:

```sh
$ gem install rule_rover
```

```sh
$ gem build rule_rover.gemspec
$ gem install rule_rover-0.1.0.gem
```

## Usage

### Propositional Logic

```ruby
RuleRover.knowledge_base(system: :propositional, engine: :model_checking) do
  assert "it's raining", :then, "take an umbrella"
  assert :not, "take an umbrella"

  # checking entailment
  entail? "it's raining" # => false
  entail? :not, "it's raining" # => true
end
```

```rb
RuleRover.knowledge_base(system: :propositional, engine: :backward_chaining) do
  assert "rainy", :or, "cloudy"
  assert "rainy", :iff, "carry an umbrella"
  assert "sunny", :and, "warm", :then, "go to the beach"
  assert :not, "snowy"
  assert ["weekend", :and, ["sunny", :or, "cloudy"]], :then, "have a picnic"
  assert "cold", :iff, ["windy", :and, "not sunny"]
  assert :not, ["rainy", :and, "sunny"], :then, "see a rainbow"

  entail? "carry an umbrella"
  entail? "go to the beach"
  entail? "have a picnic"
  entail? "see a rainbow"
end
```

### First-Order Logic

The following example shows how to create a knowledge base in first-order logic. Create function symbols like `:@philosopher`. Create predicates like `:knows` and `:writes_about`. Create constants like `"Russell"` and `"Externalworld"`. It also supports quantifiers like `:some` and `:all`. The `entail?` method checks if the given query is entailed by the knowledge base using either `:matching`, `:backward_chaining`, or `:forward_chaining`.

```ruby
RuleRover.knowledge_base(system: :first_order, engine: :forward_chaining) do
  assert [:@philosopher, var: "x"], :then, ["x", :knows, "Externalworld"]
  assert ["x", :writes_about, "Externalworld"], :then, ["x", :knows, "Externalworld"], [:do, "x", :add_empiricist]
  assert ["x", :writes_about, "Externalworld"], :then, ["x", :knows, "Externalworld"]
  assert ["x", :writes_about, "y"], :then, ["x", :thinks_about, "y"], [:do, "x", "y", :add_argues_about]
  assert ["x", :writes_about, "y"], :then, ["x", :thinks_about, "y"]
  assert "Russell", :writes_about, "Externalworld"

  entail? "Russell", :knows, "Externalworld" # => true
  match? "x", :knows, "Externalworld" # => returns all philosophers who know about the external world
end
```

#### Actions

Actions are used exclusively with backward chaining and are intended to serve as side effects within the system. Actions must be weakly "lifted", i.e. contain at least one variable, and they can only be executed on grounded rules. A rule is a definite clauses wrapped in the Conditional class. A grounded rule is a rule with no variables. It's important to use named parameters when passing values to actions. This ensures that the parameters are properly mapped to the variables within the rule to enable the use of constant values.

You can define an action with a rule by passing a block that wraps a `do_action` block.
```ruby
RuleRover.knowledge_base(system: :first_order, engine: :backward_chaining) do
  rule ["x", :writes_about, "y"], :then, ["x", :thinks_about, "y"] do
    do_action :puts_thinks_about, philosopher: "x", subject: "y" do |philosopher:, subject:|
      puts "#{philosopher} thinks about #{subject}"
    end
  end
```

You can also define actions separately from the rules and assign them to rules later on.
```ruby
  action :capitalize_subject do |subject:|
    puts subject.capitalizes
  end

  rule ["Russell", :writes_about, "x"], :then, ["Russell", :thinks_about, "x"] do
    do_action :capitalize_subject, subject: "x"
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
