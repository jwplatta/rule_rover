module RuleRover::FirstOrderLogic
  include Algorithms

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
        # TODO: @symbols.merge(sentence.symbols)
        @sentences << sentence if sentences.include?(sentence) == false
      end
    end

    def match?(*query)
      # Determines if there is a match for the given first-order logic query in the knowledge base.
      #
      # This method takes an array of strings and symbols representing a sentence in first-order logic,
      # constructs a sentence object using `sentence_factory`, and then searches for a matching sentence
      # in the knowledge base. A match is found if a valid substitution exists that makes the query sentence
      # identical to a sentence in the knowledge base.
      #
      # @param query [Array<String, Symbol>] An array representing the components of a first-order logic sentence.
      # @return [Object, nil] Returns the matching sentence object if a match is found; otherwise, returns nil.

      sentence_factory.build(*query).then do |query|
        sentences.find { |sentence| substitution.find(sentence, query)}
      end
    end

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

    def substitution
      Algorithms::Substitution
    end
  end
end