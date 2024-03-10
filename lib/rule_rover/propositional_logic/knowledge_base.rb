require_relative 'sentence_not_well_formed_error'

module PropositionalLogic
  class KnowledgeBase
    def initialize
      @connectives = [:and, :or, :then, :iff]
      @operators = [:not, :and, :or, :then, :iff]
      @symbols = Set.new([])
      @sentences = []
    end

    attr_reader :symbols, :connectives, :sentences

    def assert(*sentence)
      unless wff?(*sentence)
        raise SentenceNotWellFormedError.new(
          "Sentence is not a well-formed formula: #{sentence.inspect}"
        )
      end

      Sentence.factory(*sentence).then do |sentence|
        @symbols = Set.new(@symbols + sentence.symbols)
        @sentences << sentence
      end
    end

    def is_connective?(element)
      @connectives.include?(element)
    end

    def is_atomic?(element)
      element.is_a?(String)
    end

    def entail?(*sentence)
      Sentence.factory(*sentence).then do |query|
        check_truth_tables(
          query,
          Set.new(symbols + query.symbols).to_a,
          {}
        )
      end
    end

    # Determine if the query is true given the knowledge base by enumerating all truth tables.
    #
    # @param query [Sentence] The query to be evaluated.
    # @param symbols [Array] The list of symbols used in the query.
    # @param model [Hash] The model representing the truth values of the symbols.
    # @return [Boolean] Returns true if the query is true all models that the knowledge base is true.
    #
    # @note The time complexity of this method is O(2^n), where n is the number of unique symbols contained in the query and the knowledge base.
    def check_truth_tables(query, symbols=[], model={})
      if symbols.empty?
        !evaluate(model) or query.evaluate(model)
      else
        check_truth_tables(query, symbols[1..], model.merge({symbols.first => false})) \
          and check_truth_tables(query, symbols[1..], model.merge({symbols.first => true}))
      end
    end

    def evaluate(model)
      @sentences.all? do |sentence|
        sentence.evaluate(model)
      end
    end

    def wff?(*sentence)
      if sentence.length == 1 and is_atomic?(sentence[0])
        true
      elsif sentence.length == 2 and sentence[0] == :not
        is_atomic?(sentence[1]) or wff?(*sentence[1])
      elsif sentence.size == 3 and is_connective?(sentence[1])
        wff?(*sentence[0]) and wff?(*sentence[2])
      elsif sentence.size == 4 and is_connective?(sentence[1])
        wff?(*sentence[0]) and wff?(*sentence[2..])
      elsif sentence.size >= 2 and sentence[0] == :not and is_connective?(sentence[2])
        wff?(*sentence[0..1]) and wff?(*sentence[3..])
      else
        false
      end
    end
  end
end