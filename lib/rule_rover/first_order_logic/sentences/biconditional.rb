module RuleRover::FirstOrderLogic::Sentences
  class Biconditional
    def initialize(left, right)
      @left = left
      @right = right
    end

    attr_reader :left, :right

    def constants
      left.constants.merge(right.constants)
    end

    def evaluate(model)
      left.evaluate(model) == right.evaluate(model)
    end

    def eliminate_biconditionals
      Conjunction.new(
        Conditional.new(left.eliminate_biconditionals, right.eliminate_biconditionals),
        Conditional.new(right.eliminate_biconditionals, left.eliminate_biconditionals)
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
      "[#{left} :iff #{right}]"
    end
  end
end
