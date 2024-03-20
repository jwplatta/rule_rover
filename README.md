# RuleRover

Experimental library implementing some of the core logic programming algorithms. The library provides a simple DSL for creating a knowledge base in propositional and first-order logic.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rule_rover'
```

And then execute:

$ bundle install

Or install it yourself as:

$ gem install rule_rover

```sh
$ gem build rule_rover.gemspec
$ gem install rule_rover-0.1.0.gem
```

## Usage

### Propositional Logic

```ruby
require 'rule_rover'

RuleRover.knowledge_base(engine: :model_checking) do
  assert "joe", :then, "mary"
  assert :not, "mary"
  entail? "joe" # => false
  entail? :not, "joe" # => true
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
