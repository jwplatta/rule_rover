module RuleRover::FirstOrderLogic::Algorithms
  class Unification
    class << self
      def run(expression_x, expression_y, substitution={})
        if not substitution
          false
        elsif is_variable?(expression_x) and expression_x == expression_y
          substitution
        elsif is_variable?(expression_x)
          unify_variable(expression_x, expression_y, substitution)
        elsif is_variable?(expression_y)
          unify_variable(expression_y, expression_x, substitution)
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

      def is_variable?(expression)
        expression.is_a? RuleRover::FirstOrderLogic::Sentences::Variable
      end
    end
  end
end
