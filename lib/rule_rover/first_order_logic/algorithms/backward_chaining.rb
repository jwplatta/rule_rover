require_relative '../sentences/unification'

module RuleRover::FirstOrderLogic
  module Algorithms
    class QueryNotAtomicSentence < StandardError; end
    class BackwardChaining
      include RuleRover::FirstOrderLogic::Sentences::Unification
      include RuleRover::FirstOrderLogic::Sentences::Substitution

      class << self
        def backward_chain(kb, query)
          self.new(kb, query).backward_chain(query, {})
        end
      end

      def initialize(kb, query)
        @kb = kb
        @query = query
      end

      attr_reader :kb, :query

      def backward_chain(goal, substitution)
        backward_chain_or(goal, substitution)
      end

      def backward_chain_or(goal, substitution)
        kb.clauses.each do |rule|
          if rule.is_a? RuleRover::FirstOrderLogic::Sentences::Conditional
            antecedent_conditions, consequent = rule.conditions, rule.right
          else
            antecedent_conditions, consequent = [], rule
          end

          goal_substitution = unify(consequent, goal, substitution)

          unless goal_substitution
            next
          else
            return backward_chain_and(antecedent_conditions, goal_substitution)
          end
        end
      end

      def backward_chain_and(goals, substitution)
        if not substitution
          return
        elsif goals.empty?
          return substitution
        else
          goal, *rest = goals

          backward_chain_or(goal, substitution).then do |subst|
            backward_chain_and(rest, subst)
          end
        end
      end
    end
  end
end
