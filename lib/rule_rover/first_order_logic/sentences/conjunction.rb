module RuleRover::FirstOrderLogic::Sentences
  class Conjunction
    def initialize(left, right)
      @left = left
      @right = right
    end

    attr_reader :left, :right

    def ==(other)
      to_s == other.to_s
    end

    def eql?(other)
      self == other
    end

    def hash
      to_s.hash
    end

    def evaluate(model)
      left.evaluate(model) and right.evaluate(model)
    end

    def to_s
      "[#{left} :and #{right}]"
    end
  end
end
