# frozen_string_literal: true

require_relative "./rule_rover/version"
require_relative "./rule_rover/boolean_monkey_patch"
require_relative "./rule_rover/knowledge_base"
require_relative "./rule_rover/statements"
require_relative "./rule_rover/statements/proposition"
require_relative "./rule_rover/propositional_kb"
require_relative "./rule_rover/statements/to_cnf"
require_relative "./rule_rover/model_checker"
require_relative "./rule_rover/conjunctive_normal_form"
require_relative "./rule_rover/resolver"
require_relative "./rule_rover/forward_chaining.rb"

module RuleRover
  class Error < StandardError; end
  # Your code goes here...
end
