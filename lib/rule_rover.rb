# frozen_string_literal: true

require_relative "./rule_rover/version"
require_relative "./rule_rover/constants.rb"
require_relative "./rule_rover/sentence_not_well_formed_error.rb"
require_relative "./rule_rover/propositional_logic/knowledge_base.rb"
require_relative "./rule_rover/propositional_logic/sentences/sentence.rb"
require_relative "./rule_rover/propositional_logic/sentences/conjunction.rb"
require_relative "./rule_rover/propositional_logic/sentences/disjunction.rb"
require_relative "./rule_rover/propositional_logic/sentences/negation.rb"
require_relative "./rule_rover/propositional_logic/sentences/conditional.rb"
require_relative "./rule_rover/propositional_logic/sentences/biconditional.rb"
require_relative "./rule_rover/propositional_logic/sentences/atomic.rb"
require_relative "./rule_rover/propositional_logic/sentences/factory.rb"
require_relative "./rule_rover/propositional_logic/algorithms/logic_algorithm_base.rb"
require_relative "./rule_rover/propositional_logic/algorithms/model_checking.rb"
require_relative "./rule_rover/propositional_logic/algorithms/resolution.rb"
require_relative "./rule_rover/propositional_logic/algorithms/forward_chaining.rb"

module RuleRover
  def knowledge_base(engine: :model_checking, &block)
    puts "rule_rover knowledge_base"
    kb = RuleRover::PropositionalLogic::KnowledgeBase.new(engine=:model_checking)
    kb.instance_eval(&block)
    kb
  end

  module_function :knowledge_base
end