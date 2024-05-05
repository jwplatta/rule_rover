module RuleRover::FirstOrderLogic
  class QueryNotSinglePropositionSymbol < StandardError; end
  class KnowledgeBaseNotDefinite < StandardError; end
  class InvalidEngine < StandardError; end

  class KnowledgeBase
    include StandardizeApart
    include Algorithms::Unification
    # include Algorithms::ForwardChaining

    def initialize(engine: :forward_chaining, sentences: [], definite: false)
      @constants = Set.new
      @new_constant_count = 0
      @functions = []
      @predicates = []
      @sentences = sentences
      @engine = engine
    end

    attr_reader :constants, :functions, :predicates, :sentences, :engine

    def assert(*sentence)
      sentence_factory.build(*sentence).then do |sentence|
        @constants.merge(sentence.constants)
        standardized_sent = transform(sentence)
        @sentences << standardized_sent if sentences.include?(standardized_sent) == false
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
      # @param query Array<String|Symbol> An array representing a first-order logic sentence.
      # @return [Object, false] Returns the matching sentence object if a match is found; otherwise, returns false.

      sentence_factory.build(*query).then do |query|
        sentences.find { |sentence| unify(sentence, query)} || false
      end
    end

    def entail?(*query)
      if engine == :forward_chaining
        # raise QueryNotSinglePropositionSymbol.new unless query.size == 1 and query.first.is_a? String

        # to_clauses.then do |kb_of_clauses|
        #   raise KnowledgeBaseNotDefinite.new unless kb_of_clauses.is_definite?
        #   forward_chaining.run(kb: kb_of_clauses, query: sentence_factory.build(*query))
        # end
      else
        raise InvalidEngine.new
      end
    end

    def add_constant
      while true
        @new_constant_count += 1
        new_constant = sentence_factory.build("C#{@new_constant_count}")
        unless constants.include? new_constant
          constants << new_constant
          return new_constant
        end
      end
    end

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
