require_relative '../sentences/unification'

module RuleRover::FirstOrderLogic
  module Algorithms
    class QueryNotAtomicSentence < StandardError; end
    class BackwardChaining
      include RuleRover::FirstOrderLogic::Sentences::Unification

      class << self
        def backward_chain(kb, query)
          self.new(kb, query).backward_chain
        end
      end

      def initialize(kb, query)
        @kb = kb
        @query = query
      end

      attr_reader :kb, :query

      def backward_chain
      end

      def or(kb, goal, substitution)
      end

      def rules_for_goal(goal)
        kb.clauses.select { |clause| clause.right == goal }
      end

      def and(kb, goal, substitution)
        if not substitution
        elsif not goals
        else
         first_goal, *rest_goals = goals
        end
      end


    end
  end
end
