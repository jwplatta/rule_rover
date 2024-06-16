module RuleRover::FirstOrderLogic::Sentences
  module StandardizeApart
    attr_reader :var_count, :standardization

    def standardize_apart(expression, reset: false)
      init_var_count(reset)
      refresh_standardization
      new_sent = map(expression)
      new_sent.standardization = @standardization.dup.freeze unless reset
      new_sent
    end

    def standardization
      @standardization ||= {}
    end

    def refresh_standardization
      @standardization = {}
    end

    def standardization=(value)
      @standardization = value
    end

    private

    def init_var_count(reset)
      return unless !instance_variable_defined? :@var_count or reset

      @var_count = 0
    end

    def map(expression)
      if expression.is_a? Variable
        map_term(expression) unless standardization.include? expression
        standardization[expression]
      elsif expression.is_a? ConstantSymbol
        expression
      elsif expression.is_a? PredicateSymbol
        PredicateSymbol.new(
          name: expression.name,
          subjects: expression.subjects.map { |term| map(term) },
          objects: expression.objects.map { |term| map(term) }
        )
      elsif expression.is_a? FunctionSymbol
        FunctionSymbol.new(
          name: expression.name,
          args: expression.args.map { |term| map(term) }
        )
      elsif [Conjunction, Disjunction, Conditional, Biconditional, Equals].include? expression.class
        expression.class.new(
          map(expression.left),
          map(expression.right)
        )
      elsif expression.is_a? Negation
        Negation.new(map(expression.sentence))
      elsif [ExistentialQuantifier, UniversalQuantifier].include? expression.class
        expression.class.new(
          expression.vars.map { |var| map(var) },
          map(expression.sentence)
        )
      else
        raise NotImplementedError, "StandardizeApart not implemented for #{expression.class}"
      end
    end

    def map_term(term)
      increment_var_count
      @standardization[term] = sentence_factory.build("x_#{var_count}")
    end

    def increment_var_count
      @var_count += 1
    end

    def sentence_factory
      Factory
    end
  end
end
