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
        Enumerator.new do |yielder|
          backward_chain_or(goal, substitution, yielder)
        end.then do |enum|
          enum.next
        end
      end

      def backward_chain_or(goal, substitution, yielder)
        kb.clauses.each do |rule|
          if rule.is_a? RuleRover::FirstOrderLogic::Sentences::Conditional
            antecedent, consequent = rule.conditions, rule.right
          else
            antecedent, consequent = [], rule
          end

          backward_chain_and(antecedent, unify(consequent, goal, substitution), yielder).each do |subst|
            yielder << subst
          end
        end
      end

      def backward_chain_and(goals, substitution, yielder)
        if not substitution
          # no-op
        elsif goals.empty?
          yielder << substitution
        else
          goal, *rest = goals

          backward_chain_or(goal, substitution, yielder).each do |subst|
            backward_chain_and(rest, subst, yielder).each do |sub|
              yielder << sub
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
