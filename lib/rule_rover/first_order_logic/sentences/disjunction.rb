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

    def ==(other)
      to_s == other.to_s
    end

    def eql?(other)
      self == other
    end

    def hash
      to_s.hash
    end

    def to_s
      "[#{left} :or #{right}]"
    end
  end
end