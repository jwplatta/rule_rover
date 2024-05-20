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
        Fiber.new do
          rules_for_goal(goal).each do |rule|
            antecedent, consequent = rule.left, rule.right

            backward_chain_and(antecedent, unify(consequent, goal, substitution)).each do |subst|
              Fiber.yield subst
            end
          end
        end
      end

      def backward_chain_and(goals, substitution)
        Fiber.new do
          if !substitution
            Fiber.yield false
          elsif goals.empty?
            Fiber.yield substitution
          else
            goal, *rest = goals
            backward_chain_or(goal, substitution).each do |subst|
              backward_chain_and(rest, subst).each do |sub|
                Fiber.yield sub
              end
            end
          end
        end
      end


      def rules_for_goal(goal)
        kb.clauses.select { |clause| clause.right == goal }
      end
    end
  end
end
