# frozen_string_literal: true

require_relative "./rule_rover/version"
require_relative "./rule_rover/sentence_not_well_formed_error.rb"
require_relative "./rule_rover/sentence_not_in_cnf.rb"
require_relative "./rule_rover/propositional_logic/constants.rb"
require_relative "./rule_rover/propositional_logic/algorithms/logic_algorithm_base.rb"
require_relative "./rule_rover/propositional_logic/sentences/sentence.rb"
require_relative "./rule_rover/first_order_logic/constants.rb"
require_relative "./rule_rover/first_order_logic/sentences/substitution.rb"
require_relative "./rule_rover/first_order_logic/sentences/standardize_apart.rb"
require_relative "./rule_rover/first_order_logic/sentences/expression.rb"
require_relative "./rule_rover/first_order_logic/sentences/predicate_symbol.rb"
require_relative "./rule_rover/first_order_logic/sentences/function_symbol.rb"
require_relative "./rule_rover/first_order_logic/sentences/constant_symbol.rb"
require_relative "./rule_rover/first_order_logic/sentences/variable.rb"
require_relative "./rule_rover/first_order_logic/sentences/complex_sentence.rb"
require_relative "./rule_rover/first_order_logic/sentences/quantifier.rb"


Dir.glob(File.join(__dir__, 'rule_rover/propositional_logic/**/*.rb')).sort.each do |file|
  require_relative file
end

Dir.glob(File.join(__dir__, 'rule_rover/first_order_logic/**/*.rb')).sort.each do |file|
  require_relative file
end

module RuleRover
  def knowledge_base(system: :first_order, engine: :forward_chaining, &block)
    kb = if system == :first_order
      RuleRover::FirstOrderLogic::KnowledgeBase.new(engine: engine)
    elsif system == :propositional
      RuleRover::PropositionalLogic::KnowledgeBase.new(engine: engine)
    else
      raise ArgumentError, "Invalid system: #{system}"
    end

    kb.instance_eval(&block)
    kb
  end

  module_function :knowledge_base
end