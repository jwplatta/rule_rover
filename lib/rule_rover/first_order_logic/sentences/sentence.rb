module RuleRover::FirstOrderLogic::Sentences
  class Sentence
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

    def evaluate(model)
      raise NotImplementedError
    end
  end
end