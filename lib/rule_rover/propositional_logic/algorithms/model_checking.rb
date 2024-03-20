module RuleRover::PropositionalLogic::Algorithms
  class ModelChecking < LogicAlgorithmBase
    def entail?
      sentence_factory.build(*query).then do |query|
        check_truth_tables(
          query,
          Set.new(kb.symbols + query.symbols).to_a,
          {}
        )
      end
    end

    private

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
      kb.sentences.all? do |sentence|
        sentence.evaluate(model)
      end
    end
  end
end