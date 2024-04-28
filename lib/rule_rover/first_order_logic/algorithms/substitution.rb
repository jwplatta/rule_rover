include RuleRover::FirstOrderLogic::Sentences

module RuleRover::FirstOrderLogic::Algorithms
  class Substitution
    class << self
      def find(expression_x, expression_y)
        self.new(
          StandardizeApart.new(expression_x).transform,
          StandardizeApart.new(expression_y).transform
        ).run
      end
    end

    def initialize(expression_x, expression_y)
      @expression_x = expression_x
      @expression_y = expression_y
    end

    attr_reader :expression_x, :expression_y, :substitution

    def run
      @substitution ||= unify(expression_x, expression_y, {})
    end

    def unify(exp_x, exp_y, substitution)
      if not substitution
        false
      elsif exp_x == exp_y
        substitution
      elsif is_variable?(exp_x)
        unify_variable(exp_x, exp_y, substitution)
      elsif is_variable?(exp_y)
        unify_variable(exp_y, exp_x, substitution)
      elsif exp_x.is_a? PredicateSymbol and exp_y.is_a? PredicateSymbol
        unify(
          exp_x.subjects + exp_x.objects,
          exp_y.subjects + exp_y.objects,
          unify(exp_x.name, exp_y.name, substitution),
        )
      elsif exp_x.is_a? FunctionSymbol and exp_y.is_a? FunctionSymbol
        unify(
          exp_x.args,
          exp_y.args,
          unify(exp_x.name, exp_y.name, substitution),
        )
      elsif exp_x.is_a? Array and exp_y.is_a? Array
        unify(
          exp_x[1..],
          exp_y[1..],
          unify(exp_x.first, exp_y.first, substitution)
        )
      elsif exp_x.is_a? Negation and exp_y.is_a? Negation
        unify(
          exp_x.sentence,
          exp_y.sentence,
          unify(exp_x.class, exp_y.class, substitution)
        )
      elsif is_compound?(exp_x) and is_compound?(exp_y)
        unify(
          [exp_x.left, exp_x.right],
          [exp_y.left, exp_y.right],
          unify(exp_x.class, exp_y.class, substitution)
        )
      else
        false
      end
    end

    private

    def unify_variable(variable, expression, substitution)
      if substitution.key? variable
        unify(substitution[variable], expression, substitution)
      elsif substitution.key? expression
        unify(variable, substitution[expression], substitution)
      # TODO: implement check occur variable
      else
        substitution[variable] = expression
        substitution
      end
    end

    def is_function_or_predicate?(expression)
      expression.is_a? FunctionSymbol or \
      expression.is_a? PredicateSymbol
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
      expression.is_a? UniversalQuantifier or \
      expression.is_a? ExistentialQuantifier or \
      expression.is_a? Equals
    end

    def is_variable?(expression)
      expression.is_a? Variable
    end
  end
end
