require_relative "../sentences/unification"

module RuleRover::FirstOrderLogic
  module Algorithms
    class QueryNotAtomicSentence < StandardError; end

    class BackwardChaining
      include RuleRover::FirstOrderLogic::Sentences::Unification
      include RuleRover::FirstOrderLogic::Sentences::Substitution

      class << self
        def backward_chain(kb, query)
          new(kb, query).backward_chain(query, {})
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
          antecedent_conditions, consequent = if rule.is_a? RuleRover::FirstOrderLogic::Sentences::Conditional
            [rule.conditions, rule.right]
          else
            [[], rule]
          end

          goal_substitution = unify(consequent, goal, substitution)
          next unless goal_substitution

          subst = backward_chain_and(antecedent_conditions, goal_substitution)
          next unless subst

          kb.call_rule_actions(rule, substitution: subst)

          return subst
        end

        false
      end

      def backward_chain_and(goals, substitution)
        if goals.empty?
          substitution
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
