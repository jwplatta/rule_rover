include RuleRover::FirstOrderLogic::Sentences

module RuleRover::FirstOrderLogic::Sentences
  class StandardizeApart
    def initialize(sentence)
      @sentence = sentence
      @var_count = 0
      @mapping = {}
    end

    attr_reader :sentence, :var_count, :mapping

    def transform
      map(sentence)
      mapping
    end

    def map(expression)
      if expression.is_a? Variable
        map_term(expression) unless mapping.include? expression
      elsif expression.is_a? ConstantSymbol
        map_term(expression) unless mapping.include? expression
      elsif expression.is_a? PredicateSymbol
        (expression.subjects + expression.objects).uniq.each do |term|
          map_term(term) unless mapping.include? term
        end
      elsif expression.is_a? FunctionSymbol
        expression.args.each do |term|
          map_term(term) unless mapping.include? term
        end
      elsif [Conjunction, Disjunction, Conditional, Biconditional, Equals].include? expression.class
        map(expression.left)
        map(expression.right)
      elsif expression.is_a? Negation
        map(expression.sentence)
      elsif [ExistentialQuantifier, UniversalQuantifier].include? expression.class
        expression.vars.each do |var|
          map_term(var) unless mapping.include? var
        end

        map(expression.sentence)
      else
        raise NotImplementedError, "StandardizeApart not implemented for #{expression.class}"
      end
    end

    private

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