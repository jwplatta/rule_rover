include RuleRover::FirstOrderLogic::Sentences

module RuleRover::FirstOrderLogic
  module StandardizeApart
    def setup_standardization
      @var_count = 0
      @mapping = {}
    end

    attr_reader :var_count, :mapping

    def transform(sentence)
      map(sentence)
    end

    private

    def map(expression)
      if expression.is_a? Variable
        map_term(expression) unless mapping.include? expression
        mapping[expression]
      elsif expression.is_a? ConstantSymbol
        map_term(expression) unless mapping.include? expression
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
      @mapping[term] = sentence_factory.build("x_#{var_count}")
    end

    def increment_var_count
      @var_count += 1
    end

    def sentence_factory
      Factory
    end
  end
end