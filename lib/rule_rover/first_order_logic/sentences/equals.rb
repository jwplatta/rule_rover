module RuleRover::FirstOrderLogic::Sentences
  class Equals
    def initialize(left_term, right_term)
      @left = left_term
      @right = right_term
    end

    attr_reader :left, :right

    def to_s
      "[#{left} :equals #{right}]"
    end
  end
end