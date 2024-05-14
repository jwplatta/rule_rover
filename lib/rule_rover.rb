# frozen_string_literal: true

require_relative "./rule_rover/version"
require_relative "./rule_rover/sentence_not_well_formed_error.rb"
require_relative "./rule_rover/propositional_logic/constants.rb"
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
require_relative "./rule_rover/propositional_logic/algorithms/backward_chaining.rb"
require_relative "./rule_rover/first_order_logic/constants.rb"
require_relative "./rule_rover/first_order_logic/sentences/expression.rb"
require_relative "./rule_rover/first_order_logic/sentences/complex_sentence.rb"
require_relative "./rule_rover/first_order_logic/sentences/quantifier.rb"
require_relative "./rule_rover/first_order_logic/sentences/factory.rb"
require_relative "./rule_rover/first_order_logic/sentences/constant_symbol.rb"
require_relative "./rule_rover/first_order_logic/sentences/function_symbol.rb"
require_relative "./rule_rover/first_order_logic/sentences/predicate_symbol.rb"
require_relative "./rule_rover/first_order_logic/sentences/variable.rb"
require_relative "./rule_rover/first_order_logic/sentences/conjunction.rb"
require_relative "./rule_rover/first_order_logic/sentences/disjunction.rb"
require_relative "./rule_rover/first_order_logic/sentences/biconditional.rb"
require_relative "./rule_rover/first_order_logic/sentences/conditional.rb"
require_relative "./rule_rover/first_order_logic/sentences/negation.rb"
require_relative "./rule_rover/first_order_logic/sentences/universal_quantifier.rb"
require_relative "./rule_rover/first_order_logic/sentences/existential_quantifier.rb"
require_relative "./rule_rover/first_order_logic/sentences/equals.rb"
require_relative "./rule_rover/first_order_logic/sentences/standardize_apart.rb"
require_relative "./rule_rover/first_order_logic/sentences/unification.rb"
require_relative "./rule_rover/first_order_logic/algorithms/forward_chaining.rb"
require_relative "./rule_rover/first_order_logic/algorithms/backward_chaining.rb"
require_relative "./rule_rover/first_order_logic/knowledge_base.rb"


module RuleRover
  def knowledge_base(engine: :model_checking, &block)
    puts "rule_rover knowledge_base"
    kb = RuleRover::PropositionalLogic::KnowledgeBase.new(engine: :model_checking)
    kb.instance_eval(&block)
    kb
  end

  module_function :knowledge_base
end