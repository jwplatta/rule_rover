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
        @enum ||= Enumerator.new do |yielder|
          backward_chain_or(goal, substitution, yielder)
        end
        @enum.next
      end

      def backward_chain_or(goal, substitution, yielder)
        kb.clauses.each do |rule|
          if rule.is_a? RuleRover::FirstOrderLogic::Sentences::Conditional
            antecedent_conditions, consequent = rule.conditions, rule.right
          else
            antecedent_conditions, consequent = [], rule
          end

          goal_substitution = unify(consequent, goal, substitution)
          next unless goal_substitution

          backward_chain_and(antecedent_conditions, goal_substitution, yielder).each do |sub|
            yielder.yield sub
          end
        end
      end

      def backward_chain_and(goals, substitution, yielder)
        if not substitution
          return
        elsif goals.empty?
          yielder.yield substitution
        else
          goal, *rest = goals

          backward_chain_or(goal, substitution, yielder).reduce() do |subst|
            backward_chain_and(rest, subst, yielder).each do |sub|
              yielder.yield sub
            end
          end
        end
      end

      def rules_for_goal(goal)
        kb.clauses.select do |clause|
          if clause.is_a? RuleRover::FirstOrderLogic::Sentences::Conditional
            clause.right == goal
          else
            clause == goal
          end
        end
      end
    end
  end
end
