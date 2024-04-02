module RuleRover::FirstOrderLogic::Sentences
  class Disjunction
    def initialize(left, right)
      @left = left
      @right = right
    end

    attr_reader :left, :right

    def evaluate(model)
      left.evaluate(model) or right.evaluate(model)
    end

    def to_s
      "[#{left} :or #{right}]"
    end
  end
end