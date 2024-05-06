module RuleRover::FirstOrderLogic::Sentences
  class Negation
    include Substitution

    def initialize(sentence_or_term)
      @sentence = sentence_or_term
    end

    attr_reader :sentence

    def constants
      sentence.constants
    end

    def evaluate(model)
      not sentence.evaluate(model)
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
      "[:not #{sentence}]"
    end
  end
end