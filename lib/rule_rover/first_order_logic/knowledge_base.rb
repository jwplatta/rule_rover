module RuleRover::FirstOrderLogic
  class QueryNotSinglePropositionSymbol < StandardError; end
  class KnowledgeBaseNotDefinite < StandardError; end
  class InvalidEngine < StandardError; end

  class KnowledgeBase
    def initialize(engine: :forward_chaining, sentences: [])
      @constants = []
      @functions = []
      @predicates = []
      @sentences = sentences
      @engine = engine
    end

    attr_reader :constants, :functions, :predicates, :sentences, :engine

    def assert(*sentence)
      sentence_factory.build(*sentence).then do |sentence|
        # @symbols.merge(sentence.symbols)
        @sentences << sentence if sentences.include?(sentence) == false
      end
    end

    def match?(*querty); end

    def entail?(*query); end

    def connectives
      @connectives ||= RuleRover::FirstOrderLogic::CONNECTIVES
    end

    def operators
      @operators ||= RuleRover::FirstOrderLogic::OPERATORS
    end

    def quantifiers
      @quantifiers ||= RuleRover::FirstOrderLogic::QUANTIFIERS
    end

    def sentence_factory
      RuleRover::FirstOrderLogic::Sentences::Factory
    end
  end
end