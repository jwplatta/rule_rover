# require_relative 'sentence_not_well_formed_error'
require 'set'

module RuleRover::PropositionalLogic
  class KnowledgeBase
    def initialize(engine: :model_checking, sentences: [])
      @symbols = Set.new([])
      @sentences = sentences
      @engine = engine
    end

    attr_reader :symbols, :sentences, :engine

    def assert(*sentence)
      sentence_factory.build(*sentence).then do |sentence|
        @symbols = Set.new(symbols + sentence.symbols)
        @sentences << sentence if sentences.include?(sentence) == false
      end
    end

    def entail?(*query)
      if engine == :model_checking
        ModelChecking.run(self, *query)
      elsif engine == :resolution
        Resolution.run(self, *query)
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
  end
end