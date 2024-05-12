require_relative '../sentences/unification'

module RuleRover::FirstOrderLogic
  module Algorithms
    class QueryNotAtomicSentence < StandardError; end
    class ForwardChaining
      include RuleRover::FirstOrderLogic::Sentences::Unification

      """
      - Requirements:
      - Assumes that the knowledge base is a set of definite clauses
      - Assumes the sentences have been standardized apart
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
        # TODO: raise if the query is not an atomic sentence
        raise QueryNotAtomicSentence.new unless TERM_CLASSES.include? query.class
        @kb = kb
        @query = query
      end

      attr_reader :kb, :query

      def forward_chain(kb, query)
        kb.sentences.each { |sentence| return true if unify(sentence, query) }

        while true
          new_sentences = []
          kb.clauses.each do |clause|
            antecedent, consequent = antecedent_and_consequent(clause)

            substitutions(kb.constants.to_a, antecedent.variables.to_a).each do |substitution|
              _antecedent = antecedent.substitute(substitution)

              conjuncts = conjuncts_to_a(_antecedent)

              if conjuncts.all? { |conj| kb.sentences.any? { |sent| unify(sent, conj) } }
                _consequent = consequent.substitute(substitution)

                if !kb.sentences.any? { |sent| unify(sent, _consequent) }
                  new_sentences << _consequent
                  return true if unify(_consequent, query)
                end
              end
            end
          end

          if new_sentences.empty?
            return false
          else
            new_sentences.each { |sentence| kb.assert_sentence(sentence) }
          end
        end

        false
      end

      def conjuncts_to_a(conjunction)
        conjuncts = []
        frontier = [conjunction]

        while frontier.any?
          conj = frontier.shift

          if TERM_CLASSES.include? conj.class
            conjuncts << conj
          elsif conj.is_a? RuleRover::FirstOrderLogic::Sentences::Conjunction
            conjuncts << conj.left
            conjuncts << conj.right
          end
        end
        conjuncts
      end

      def antecedent_and_consequent(clause)
        # NOTE: assumes that the clause is a definite clause
        if TERM_CLASSES.include? clause.class
          [clause, clause]
        elsif clause.is_a? RuleRover::FirstOrderLogic::Sentences::Conditional
          [clause.left, clause.right]
        else
          [nil, nil]
        end
      end

      def substitutions(constants, variables)
        subs = variables.product(constants).map do |var, const|
          { var => const }
        end
        subs << {} # NOTE: include the empty substitution
        subs
      end
    end
  end
end
