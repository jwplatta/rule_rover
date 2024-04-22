module RuleRover::FirstOrderLogic::Sentences
  class Conditional
    def initialize(left, right)
      @left = left
      @right = right
    end

    attr_reader :left, :right

    def evaluate(model)
      not left.evaluate(model) or right.evaluate(model)
    end

    def eliminate_conditionals
      Disjunction.new(
        Negation.new(left.eliminate_conditionals),
        right.eliminate_conditionals
      )
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
      "[#{left} :then #{right}]"
    end
  end
end
