module RuleRover::FirstOrderLogic
  class QueryNotSinglePropositionSymbol < StandardError; end
  class KnowledgeBaseNotDefinite < StandardError; end
  class InvalidEngine < StandardError; end
  class SentenceIsNotAnExpression < StandardError; end
  class SentenceAndActionParamsMustMatch < ArgumentError; end

  class KnowledgeBase
    include Sentences::StandardizeApart
    include Sentences::Unification

    def initialize(engine: :forward_chaining, sentences: [], definite: false)
      raise InvalidEngine.new("Invalid engine: #{engine}") unless ENGINES.include?(engine)

      @constants = Set.new
      @new_constant_count = 0
      @functions = []
      @predicates = []
      @sentences = sentences
      @engine = engine
      @action_registry = init_action_registry(self)
    end

    attr_reader :constants, :functions, :predicates, :sentences, :engine, :action_registry

    # Adds a new sentence to the knowledge base.
    #
    # @param sentence_parts [Array] the parts of the sentence to be added
    # @return [void]
    def assert(*sentence_parts, **_kwargs, &block)
      sentence_factory.build(*sentence_parts).then do |sentence|
        # TODO: retract sentence if it already exists
        # Only if it is completely grounded - no variables

        # TODO: checks, e.g. is it a rule? constant? etc.
        @constants.merge(sentence.constants)
        standardized_sent = standardize_apart(sentence, store: true)

        if sentences.include?(standardized_sent) == false
          if block_given?
            action_name, mapped_params = instance_eval(&block)
            action_registry.map_rule_to_action(
              standardized_sent,
              action_name,
              **mapped_params
            )
          end

          @sentences << standardized_sent
        end
      end
    end

    def retract(*sentence_parts)
      match?(*sentence_parts).each do |sentence|
        @sentences.delete(sentence)
      end
    end

    def rule(*sentence_parts, **kwargs, &block)
      # TODO: check that the sentence is a definite clause
      # before asserting it
      assert(*sentence_parts, **kwargs, &block)
    end

    def fact(*sentence_parts, **kwargs, &block)
      assert(*sentence_parts, **kwargs, &block)
    end

    def constant(name)
      sentence_factory.build(name).then do |sentence|
        @constants.merge(sentence.constants)
      end
    end

    def do_action(name, **mapped_params, &block)
      action(name, **mapped_params, &block)
    end

    def action(name, **mapped_params, &block)
      # NOTE: there's currently no way to update an existing action.
      act = if block_given? and !action_registry.exists?(name)
        action_registry.add(name, &block)
      else
        action_registry.find(name)
      end

      if mapped_params.any? and !(mapped_params.keys.sort == act.param_names.sort)
        raise SentenceAndActionParamsMustMatch.new
      end

      [name, mapped_params]
    end

    def call_rule_actions(rule, substitution: {})
      # NOTE: might need to apply the substitution inside the action registry
      action_registry.call_rule_actions(substitution.any? ? rule.substitute(substitution) : rule)
    end

    # This method takes a `sentence` object and adds it to the knowledge base.
    # It first merges the constants from the sentence with the existing constants in the knowledge base.
    # Then, it standardizes the sentence apart to avoid variable name conflicts.
    #
    # @param sentence [Expression] The sentence object to be added to the knowledge base.
    # @return [void]
    def assert_sentence(sentence)
      raise SentenceIsNotAnExpression.new unless sentence.is_a? Sentences::Expression

      @constants.merge(sentence.constants)
      standardized_sent = standardize_apart(sentence, store: true)
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
        sentences.select { |sentence| unify(sentence, query) } || []
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

    # Substitutes variables in the knowledge base with the provided substitution.
    #
    # @param subst [Hash] A hash containing variable substitutions.
    # @return [KnowledgeBase] A new knowledge base with substituted sentences.
    def substitute(subst = {})
      KnowledgeBase.new(engine: engine).tap do |new_kb|
        sentences.each do |sentence|
          new_kb.assert_sentence(sentence.substitute(subst))
        end
      end
    end

    private

    def definite_clause?(sentence)
      if Sentences::ATOMIC_SENTENCE_CLASSES.include? sentence.class
        true
      elsif sentence.is_a? Sentences::Conditional and Sentences::ATOMIC_SENTENCE_CLASSES.include? sentence.right.class
        frontier = [sentence.left]
        while frontier.any?
          current = frontier.shift

          if current.is_a? Sentences::Conjunction
            frontier.push(current.left, current.right)
          elsif Sentences::ATOMIC_SENTENCE_CLASSES.include? current.class
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

    def init_action_registry(kb)
      ActionRegistry.new(kb: kb)
    end
  end
end
