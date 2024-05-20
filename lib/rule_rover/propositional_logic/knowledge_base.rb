# require_relative 'sentence_not_well_formed_error'
require 'set'

module RuleRover::PropositionalLogic
  class QueryNotSinglePropositionSymbol < StandardError; end
  class KnowledgeBaseNotDefinite < StandardError; end
  class InvalidEngine < StandardError; end

  class KnowledgeBase
    def initialize(engine: :model_checking, sentences: [])
      @symbols = sentences.any? ? sentences.reduce(Set.new) { |acc, sent| acc.merge(sent.symbols) } : Set.new
      @sentences = sentences

      raise InvalidEngine.new unless valid_engines.include?(engine)
      @engine = engine
    end

    attr_reader :symbols, :sentences, :engine

    def assert(*sentence_parts)
      sentence_factory.build(*sentence_parts).then do |sentence|
        @symbols.merge(sentence.symbols)
        @sentences << sentence if sentences.include?(sentence) == false
      end
    end

    def entail?(*query)
      if engine == :model_checking
        model_checking.run(
          kb: self,
          query: sentence_factory.build(*query)
        )
      elsif engine == :resolution
        to_clauses.then do |kb_of_clauses|
          resolution.run(kb: kb_of_clauses, query: sentence_factory.build(*query))
        end
      elsif engine == :forward_chaining
        raise QueryNotSinglePropositionSymbol.new unless query.size == 1 and query.first.is_a? String

        to_clauses.then do |kb_of_clauses|
          raise KnowledgeBaseNotDefinite.new unless kb_of_clauses.is_definite?
          forward_chaining.run(kb: kb_of_clauses, query: sentence_factory.build(*query))
        end
      elsif engine == :backward_chaining
        to_clauses.then do |kb_of_clauses|
          backward_chaining.run(
            kb: kb_of_clauses,
            query: sentence_factory.build(*query)
          )
        end
      else
        raise InvalidEngine.new
      end
    end

    def connectives
      @connectives ||= RuleRover::PropositionalLogic::CONNECTIVES
    end

    def operators
      @operators ||= RuleRover::PropositionalLogic::OPERATORS
    end

    def to_clauses
      sentences.map(&:to_cnf).then do |cnf_sentences|
        cnf_sentences.map do |sent|
          frontier = [sent]
          disjunctions = []
          while frontier.any?
            sent = frontier.shift
            if sent.is_a? Sentences::Conjunction
              frontier << sent.left
              frontier << sent.right
            elsif sent.is_a? Sentences::Disjunction or sent.is_atomic?
              disjunctions << sent
            else
              raise StandardError.new("Unexpected sentence type: #{sent.class}")
            end
          end
          disjunctions
        end.flatten.uniq
      end.then do |disjunctions|
        KnowledgeBase.new(
          engine: engine,
          sentences: disjunctions
        )
      end
    end

    def is_definite?
      @is_definite ||= sentences.all?(&:is_definite?)
    end

    private

    def sentence_factory
      Sentences::Factory
    end

    def resolution
      RuleRover::PropositionalLogic::Algorithms::Resolution
    end

    def valid_engines
      RuleRover::PropositionalLogic::ENGINES
    end

    def model_checking
      RuleRover::PropositionalLogic::Algorithms::ModelChecking
    end

    def forward_chaining
      RuleRover::PropositionalLogic::Algorithms::ForwardChaining
    end

    def backward_chaining
      RuleRover::PropositionalLogic::Algorithms::BackwardChaining
    end
  end
end