module RuleRover::FirstOrderLogic::Sentences
  module Unification
    def unify(expression_x, expression_y, mapping={})
      unify_expressions(expression_x, expression_y, mapping.dup)
    end

    private

    def unify_expressions(exp_x, exp_y, mapping)
      if exp_x == exp_y or not mapping
        mapping
      elsif is_variable?(exp_x)
        unify_variable(exp_x, exp_y, mapping)
      elsif is_variable?(exp_y)
        unify_variable(exp_y, exp_x, mapping)
      elsif exp_x.is_a? PredicateSymbol and exp_y.is_a? PredicateSymbol
        unify_expressions(
          exp_x.subjects + exp_x.objects,
          exp_y.subjects + exp_y.objects,
          unify_expressions(exp_x.name, exp_y.name, mapping),
        )
      elsif exp_x.is_a? FunctionSymbol and exp_y.is_a? FunctionSymbol
        unify_expressions(
          exp_x.args,
          exp_y.args,
          unify_expressions(exp_x.name, exp_y.name, mapping),
        )
      elsif exp_x.is_a? Array and exp_y.is_a? Array
        unify_expressions(
          exp_x[1..],
          exp_y[1..],
          unify_expressions(exp_x.first, exp_y.first, mapping)
        )
      elsif exp_x.is_a? Negation and exp_y.is_a? Negation
        unify_expressions(
          exp_x.sentence,
          exp_y.sentence,
          unify_expressions(exp_x.class, exp_y.class, mapping)
        )
      elsif is_compound?(exp_x) and is_compound?(exp_y)
        unify_expressions(
          [exp_x.left, exp_x.right],
          [exp_y.left, exp_y.right],
          unify_expressions(exp_x.class, exp_y.class, mapping)
        )
      else
        false
      end
    end

    def unify_variable(variable, expression, mapping)
      if mapping.key? variable
        unify_expressions(mapping[variable], expression, mapping)
      elsif mapping.key? expression
        unify_expressions(variable, mapping[expression], mapping)
      # TODO: implement check occur variable
      # https://github.com/aimacode/aima-python/blob/master/logic.py#L1758
      else
        mapping[variable] = expression
        mapping
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
