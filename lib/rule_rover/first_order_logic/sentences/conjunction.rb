module RuleRover::FirstOrderLogic::Sentences
  class Conjunction
    def initialize(left, right)
      @left = left
      @right = right
    end

    attr_reader :left, :right

    def evaluate(model)
      left.evaluate(model) and right.evaluate(model)
    end

    def to_s
      "[#{left} :and #{right}]"
    end
  end
end