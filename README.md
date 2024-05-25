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

The following example shows how to create a knowledge base in first-order logic. Create function symbols like `:@philosopher`. Create predicates like `:knows` and `:writes_about`. Create constants like `"Russell"` and `"ExternalWorld"`.

```ruby
RuleRover.knowledge_base(system: :first_order, engine: :backward_chaining) do
  assert [:@philosopher, "x"], :then, ["x", :knows, "ExternalWorld"]
  assert ["x", :writes_about, "ExternalWorld"], :then, ["x", :knows, "ExternalWorld"]
  assert "Russell", :writes_about, "ExternalWorld"

  entail? "Russell", :knows, "ExternalWorld"
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
