# require_relative 'sentence_not_well_formed_error'
require 'set'

module RuleRover::PropositionalLogic
  class QueryNotSinglePropositionSymbol < StandardError; end
  class KnowledgeBaseNotDefinite < StandardError; end

  class KnowledgeBase
    def initialize(engine: :model_checking, sentences: [])
      @symbols = sentences.any? ? sentences.reduce(Set.new) { |acc, sent| acc.merge(sent.symbols) } : Set.new
      @sentences = sentences
      @engine = engine
    end

    attr_reader :symbols, :sentences, :engine

    def assert(*sentence)
      sentence_factory.build(*sentence).then do |sentence|
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
        to_cnf.then do |cnf_kb|
          resolution.run(kb: cnf_kb, query: sentence_factory.build(*query))
        end
      elsif engine == :forward_chaining
        unless query.size == 1 and query.first.is_a? String
          raise QueryNotSinglePropositionSymbol.new("Query must be a single proposition symbol")
        end

        to_cnf.then do |cnf_kb|
          raise KnowledgeBaseNotDefinite.new("Knowledge base is not definite") unless cnf_kb.is_definite?
          forward_chaining.run(kb: cnf_kb, query: sentence_factory.build(*query))
        end
      else
        raise ArgumentError.new("Engine not supported: #{engine}")
      end
    end

    def connectives
      @connectives ||= RuleRover::CONNECTIVES
    end

    def operators
      @operators ||= RuleRover::OPERATORS
    end

    def to_cnf
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

    def model_checking
      RuleRover::PropositionalLogic::Algorithms::ModelChecking
    end

    def forward_chaining
      RuleRover::PropositionalLogic::Algorithms::ForwardChaining
    end
  end
end