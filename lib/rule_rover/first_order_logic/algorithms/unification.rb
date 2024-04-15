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
        elsif is_compound?(expression_x) and is_compound?(expression_y)

        elsif expression_x.is_a? Array and expression_y.is_a? Array
          false
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

      def is_compound?(expression)
        expression.is_a? RuleRover::FirstOrderLogic::Sentences::Conditional or \
        expression.is_a? RuleRover::FirstOrderLogic::Sentences::Biconditional or \
        expression.is_a? RuleRover::FirstOrderLogic::Sentences::Conjunction or \
        expression.is_a? RuleRover::FirstOrderLogic::Sentences::Disjunction or \
        expression.is_a? RuleRover::FirstOrderLogic::Sentences::Negation or \
        expression.is_a? RuleRover::FirstOrderLogic::Sentences::UniversalQuantifier or \
        expression.is_a? RuleRover::FirstOrderLogic::Sentences::ExistentialQuantifier or \
        expression.is_a? RuleRover::FirstOrderLogic::Sentences::Equals
      end

      def is_variable?(expression)
        expression.is_a? RuleRover::FirstOrderLogic::Sentences::Variable
      end
    end
  end
end
