module RuleRover::FirstOrderLogic
  module Algorithms
    module ForwardChaining
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
      def forward_chain(kb, *query)
        binding.pry
      end

      def self.definite_clause?(sentence)
        return false unless sentence.is_a? RuleRover::FirstOrderLogic::Sentences::Disjunction

        term_classes = [
          RuleRover::FirstOrderLogic::Sentences::PredicateSymbol,
          RuleRover::FirstOrderLogic::Sentences::FunctionSymbol,
          RuleRover::FirstOrderLogic::Sentences::ConstantSymbol,
          RuleRover::FirstOrderLogic::Sentences::Variable,
        ]
        frontier = [sentence.left, sentence.right]
        count = 0

        while frontier.any?
          current = frontier.shift

          if current.is_a? RuleRover::FirstOrderLogic::Sentences::Disjunction
            frontier.push(current.left, current.right)
          elsif current.is_a? RuleRover::FirstOrderLogic::Sentences::Negation
            puts 'negation'
          elsif term_classes.include? current.class
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
