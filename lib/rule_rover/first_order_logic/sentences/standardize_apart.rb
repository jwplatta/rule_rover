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

      return mapping
    end

    def map(expression)
      if expression.is_a? Variable
        unless mapping.include? expression
          map_term(expression)
        end
      elsif expression.is_a? ConstantSymbol
        unless mapping.include? expression
          map_term(expression)
        end
      elsif expression.is_a? PredicateSymbol
        (expression.subjects + expression.objects).uniq.each do |term|
          unless mapping.include? term
            map_term(term)
          end
        end
      elsif expression.is_a? FunctionSymbol
        expression.args.each do |term|
          unless mapping.include? term
            map_term(term)
          end
        end
      elsif [Conjunction, Disjunction, Conditional, Biconditional].include? expression.class
        map(expression.left)
        map(expression.right)
      elsif expression.is_a? Negation
        map(expression.sentence)
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