module RuleRover::FirstOrderLogic
  class QueryNotSinglePropositionSymbol < StandardError; end
  class KnowledgeBaseNotDefinite < StandardError; end
  class InvalidEngine < StandardError; end

  class KnowledgeBase
    include Sentences::StandardizeApart
    include Sentences::Unification

    ATOMIC_SENTENCE_CLASSES=[
      RuleRover::FirstOrderLogic::Sentences::PredicateSymbol,
      RuleRover::FirstOrderLogic::Sentences::FunctionSymbol,
      RuleRover::FirstOrderLogic::Sentences::ConstantSymbol,
      RuleRover::FirstOrderLogic::Sentences::Variable
    ]

    def initialize(engine: :forward_chaining, sentences: [], definite: false)
      unless ENGINES.include?(engine)
        raise InvalidEngine.new("Invalid engine: #{engine}")
      end

      @constants = Set.new
      @new_constant_count = 0
      @functions = []
      @predicates = []
      @sentences = sentences
      @engine = engine
    end

    attr_reader :constants, :functions, :predicates, :sentences, :engine

    # Adds a new sentence to the knowledge base.
    #
    # @param sentence_parts [Array] the parts of the sentence to be added
    # @return [void]
    def assert(*sentence_parts)
      sentence_factory.build(*sentence_parts).then do |sentence|
        @constants.merge(sentence.constants)
        standardized_sent = standardize_apart(sentence)
        @sentences << standardized_sent if sentences.include?(standardized_sent) == false
      end
    end

    # This method takes a `sentence` object and adds it to the knowledge base.
    # It first merges the constants from the sentence with the existing constants in the knowledge base.
    # Then, it standardizes the sentence apart to avoid variable name conflicts.
    #
    # @param sentence [Expression] The sentence object to be added to the knowledge base.
    # @return [void]
    def assert_sentence(sentence)
      @constants.merge(sentence.constants)
      standardized_sent = standardize_apart(sentence)
      @sentences << standardized_sent if sentences.include?(standardized_sent) == false
    end

    def clauses
      @clauses ||= sentences.select { |sentence| definite_clause?(sentence) }
    end

    def entail?(*query)
      if engine == :forward_chaining
        forward_chain(*query)
      elsif engine == :backward_chaining
        backward_chain(*query)
      elsif engine == :matching
        match?(*query)
      else
        raise InvalidEngine.new
      end
    end

    # Determines if there is a match for the given first-order logic query in the knowledge base.
    #
    # This method takes an array of strings and symbols representing a sentence in first-order logic,
    # constructs a sentence object using `sentence_factory`, and then searches for a matching sentence
    # in the knowledge base. A match is found if a valid substitution exists that makes the query sentence
    # identical to a sentence in the knowledge base.
    #
    # @param query Array<String|Symbol> An array representing a first-order logic sentence.
    # @return [Object, false] Returns the matching sentence object if a match is found; otherwise, returns false.
    def match?(*query)
      sentence_factory.build(*query).then do |query|
        sentences.find { |sentence| unify(sentence, query)} || false
      end
    end

    # Creates a new constant for existential instantiation in first-order logic.
    #
    # This method generates a new constant by incrementing the `@new_constant_count`
    # and appending it to the letter 'C'. The generated constant is then checked
    # against the existing constants in the knowledge base. If the constant is not
    # already present, it is added to the `constants` array and returned.
    #
    # @return [ConstantSymbol] The newly created constant.
    def create_constant
      while true
        @new_constant_count += 1
        new_constant = sentence_factory.build("C#{@new_constant_count}")
        unless constants.include? new_constant
          constants << new_constant
          return new_constant
        end
      end
    end

    # Substitutes variables in the knowledge base with the provided mapping.
    #
    # @param mapping [Hash] A hash containing variable substitutions.
    # @return [KnowledgeBase] A new knowledge base with substituted sentences.
    def substitute(mapping={})
      KnowledgeBase.new(engine: engine).tap do |new_kb|
        sentences.each do |sentence|
          new_kb.assert_sentence(sentence.substitute(mapping))
        end
      end
    end

    private

    def definite_clause?(sentence)
      if ATOMIC_SENTENCE_CLASSES.include? sentence.class
        true
      elsif sentence.is_a? Sentences::Conditional and ATOMIC_SENTENCE_CLASSES.include? sentence.right.class
        frontier = [sentence.left]
        while frontier.any?
          current = frontier.shift

          if current.is_a? Sentences::Conjunction
            frontier.push(current.left, current.right)
          elsif ATOMIC_SENTENCE_CLASSES.include? current.class
            next
          else
            return false
          end
        end

        true
      else
        false
      end
    end

    def forward_chain(*query)
      ForwardChaining.forward_chain(self, sentence_factory.build(*query))
    end

    def backward_chain(*query)
      BackwardChaining.backward_chain(self, sentence_factory.build(*query))
    end

    def sentence_factory
      RuleRover::FirstOrderLogic::Sentences::Factory
    end
  end
end
