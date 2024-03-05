# RuleRover

### TODO

- The Resolution module is broken for `PropositionalKB`
- ForwardChaining for `PropositionalKB`
- Backtracking for `PropositionalKB`
- Move the Predicate class from `statements.rb` to `statements/predicate.rb`
- Add PredicateKB class
- Refactor CNF and other `#entails?` algos for predicates
- Implement Rete algorithm for `PredicateKB`

## Notes

- Currently, it's assumed that the KnowledgeBase will have a truth value for all AtomicStatments in the model. Perhaps, it should be possible for the KnowledgeBase to "know about" fewer AtomicStatements than are in the model.
- https://ulfurinn.github.io/wongi-engine/docs/basics/starting-up/


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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/rule_rover.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
