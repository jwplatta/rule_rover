require_relative '../sentences/unification'

module RuleRover::FirstOrderLogic
  module Algorithms
    class QueryNotAtomicSentence < StandardError; end
    class ForwardChaining
      include RuleRover::FirstOrderLogic::Sentences::Unification
      # The ForwardChaining class implements the
      # forward chaining algorithm for inference in a knowledge base.

      # Requirements:
      # - The knowledge base is a set of definite clauses
      # - The sentences are standardized apart
      # - The query is an atomic sentence
      # - Existential instantiation

      # Steps:
      # 1. Try to unify the query with an existing clause in the database
      # 2. If not, then loop through all the clauses in the database
      class << self
        # Performs forward chaining on the knowledge base (kb)
        # to derive the truth value of the given query.
        #
        # @param kb [KnowledgeBase] The knowledge base.
        # @param query [Expression] The query to be evaluated.
        # @return [Boolean] The truth value of the query.
        def forward_chain(kb, query)
          self.new(kb, query).forward_chain
        end
      end

      def initialize(kb, query)
        raise QueryNotAtomicSentence.new unless kb.class::ATOMIC_SENTENCE_CLASSES.include? query.class
        @kb = kb
        @query = query
      end

      attr_reader :kb, :query

      def forward_chain
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

          if kb.class::ATOMIC_SENTENCE_CLASSES.include? conj.class
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
        if kb.class::ATOMIC_SENTENCE_CLASSES.include? clause.class
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
