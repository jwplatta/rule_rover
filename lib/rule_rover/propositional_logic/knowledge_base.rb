# require_relative 'sentence_not_well_formed_error'
require 'set'

module RuleRover::PropositionalLogic
  class KnowledgeBase
    def initialize(engine=:model_checking)
      @symbols = Set.new([])
      @sentences = []
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

    private

    def sentence_factory
      Sentences::Factory
    end
  end
end