module RuleRover::FirstOrderLogic::Sentences
  class Quantifier
    include Expression

    def initialize(vars, sentence)
      @vars = vars
      @sentence = sentence
    end

    attr_reader :vars, :sentence

    def constants
      sentence.constants
    end

    def variables
      Set.new(vars).merge(sentence.variables)
    end
  end
end
