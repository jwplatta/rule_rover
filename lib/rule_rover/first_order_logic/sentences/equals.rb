module RuleRover::FirstOrderLogic::Sentences
  class Equals
    include Expression

    def initialize(left_term, right_term)
      @left = left_term
      @right = right_term
    end

    attr_reader :left, :right

    def constants
      left.constants.merge(right.constants)
    end

    def to_s
      "[#{left} :equals #{right}]"
    end
  end
end
