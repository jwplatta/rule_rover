module RuleRover::FirstOrderLogic::Sentences
  class Sentence
    def initialize(left, right)
      @left = left
      @right = right
    end

    attr_reader :left, :right

    def variables
      left.vars.merge(right.vars)
    end

    def evaluate(model)
      raise NotImplementedError
    end
  end
end