module RuleRover::FirstOrderLogic::Algorithms
  class Unification
    class << self
      def run(expression_x, expression_y, substitution={})
        if not substitution
          false
        elsif same_variable?(expression_x, expression_y)
          substitution
        else
          false
        end
      end

      def unify_variable(variable, expression, substitution)
      end

      def same_variable?(expression_x, expression_y)
        /^[a-z]/.match?(expression_x) and /^[a-z]/.match?(expression_y) and expression_x == expression_y
      end
    end
  end
end
