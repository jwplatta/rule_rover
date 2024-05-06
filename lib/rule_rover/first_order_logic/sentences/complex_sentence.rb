module RuleRover::FirstOrderLogic::Sentences
  class ComplexSentence
    include Expression

    def initialize(left, right)
      @left = left
      @right = right
    end

    attr_reader :left, :right

    def constants
      left.constants.merge(right.constants)
    end

    def variables
      left.variables.merge(right.variables)
    end
  end
end
