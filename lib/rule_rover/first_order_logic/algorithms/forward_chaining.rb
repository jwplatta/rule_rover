require_relative '../sentences/unification'

module RuleRover::FirstOrderLogic
  module Algorithms
    class ForwardChaining
      include RuleRover::FirstOrderLogic::Sentences::Unification

      """
      - Requirements:
      - only definite clauses
      - need to be able to apply substitutions to the clauses
      - query needs to be an atomic sentence
      - existential instantiation

      - STEPS
      - 1. try to unify the query with an existing clause in the database
      - 2. if not, then loop through all the clauses in the database
      """
      TERM_CLASSES = [
        RuleRover::FirstOrderLogic::Sentences::PredicateSymbol,
        RuleRover::FirstOrderLogic::Sentences::FunctionSymbol,
        RuleRover::FirstOrderLogic::Sentences::ConstantSymbol,
        RuleRover::FirstOrderLogic::Sentences::Variable,
      ]

      class << self
        def forward_chain(kb, query)
          self.new(kb, query).forward_chain(kb, query)
        end
      end

      def initialize(kb, query)
        @kb = kb
        @query = query
      end

      attr_reader :kb, :query

      def forward_chain(kb, query)
        kb.sentences.each do |sentence|
          return true if unify(sentence, query)
        end
        false
      end

      def substitutions(constants, variables)
        variables.product(constants).map do |variable, constant|
          { variable => constant }
        end
      end

      def definite_clause?(sentence)
        return false unless sentence.is_a? RuleRover::FirstOrderLogic::Sentences::Disjunction

        frontier = [sentence.left, sentence.right]
        count = 0

        while frontier.any?
          current = frontier.shift

          if current.is_a? RuleRover::FirstOrderLogic::Sentences::Disjunction
            frontier.push(current.left, current.right)
          elsif current.is_a? RuleRover::FirstOrderLogic::Sentences::Negation
            next
          elsif TERM_CLASSES.include? current.class
            count += 1
          else
            return false
          end
        end

        count == 1
      end
    end
  end
end
