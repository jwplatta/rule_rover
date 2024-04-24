include RuleRover::FirstOrderLogic::Sentences

module RuleRover::FirstOrderLogic::Algorithms
  class Unification
    class << self
      def unify(expression_x, expression_y)
        self.new(
          StandardizeApart(expression_x).transform,
          StandardizeApart(expression_y).transform
        ).unify
      end
    end

    def initialize(expression_x, expression_y)
      @expression_x = expression_x
      @expression_y = expression_y
    end

    attr_reader :expression_x, :expression_y

    def unify
    end

    def run
      if not substitution
        false
      elsif expression_x == expression_y
        substitution
      elsif is_variable?(expression_x)
        unify_variable(expression_x, expression_y, substitution)
      elsif is_variable?(expression_y)
        unify_variable(expression_y, expression_x, substitution)
      elsif is_term?(expression_x) and is_term?(expression_y)
        run(
          get_standardization(expression_x),
          get_standardization(expression_y),
          run(expression_x.name, expression_y.name, substitution)
        )
      elsif is_compound?(expression_x) and is_compound?(expression_y)
        run(
          [expression_x.left, expression_x.right],
          [expression_x.left, expression_y.right],
          run(expression_x.class, expression_y.class, substitution)
        )
      elsif expression_x.is_a? Array and expression_y.is_a? Array
        run(
          expression_x[1..],
          expression_y[1..],
          run(expression_x.first, expression_y.first, substitution)
        )
      else
        false
      end
    end

    def unify_variable(variable, expression, substitution)
      if substitution.key? variable
        run(substitution[variable], expression, substitution)
      elsif substitution.key? expression
        run(variable, substitution[expression], substitution)
      # TODO: check occur variable, expression
      else
        substitution[variable] = expression
        substitution
      end
    end

    def is_term?(expression)
      expression.is_a? FunctionSymbol or \
      expression.is_a? PredicateSymbol
    end

    def is_compound?(expression)
      expression.is_a? Conditional or \
      expression.is_a? Biconditional or \
      expression.is_a? Conjunction or \
      expression.is_a? Disjunction or \
      expression.is_a? Negation or \
      expression.is_a? UniversalQuantifier or \
      expression.is_a? ExistentialQuantifier or \
      expression.is_a? Equals
    end

    def is_variable?(expression)
      expression.is_a? Variable
    end
  end
end
