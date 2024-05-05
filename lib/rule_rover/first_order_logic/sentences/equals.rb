require_relative '../substitution'

module RuleRover::FirstOrderLogic::Sentences
  class Equals
    include RuleRover::FirstOrderLogic::Substitution

    def initialize(left_term, right_term)
      @left = left_term
      @right = right_term
    end

    attr_reader :left, :right

    def constants
      left.constants.merge(right.constants)
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
      "[#{left} :equals #{right}]"
    end
  end
end
