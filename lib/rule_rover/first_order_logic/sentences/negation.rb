module RuleRover::FirstOrderLogic::Sentences
  class Negation
    include Expression

    def initialize(sentence_or_term)
      @sentence = sentence_or_term
    end

    attr_reader :sentence

    def constants
      sentence.constants
    end

    def variables
      sentence.variables
    end

    def evaluate(model)
      !sentence.evaluate(model)
    end

    def to_s
      "[:not #{sentence}]"
    end
  end
end
