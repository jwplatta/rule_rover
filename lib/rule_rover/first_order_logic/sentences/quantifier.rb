module RuleRover::FirstOrderLogic::Sentences
  class Quantifier
    include Expression

    def initialize(vars, sentence)
      @vars = vars
      @sentence = sentence
    end

    attr_reader :vars, :sentence

    def lifted?
      # WARNING: this might cause a bug if the sentence is in fact grounded.
      true
    end

    def grounded?
      false
    end

    def constants
      sentence.constants
    end

    def variables
      Set.new(vars).merge(sentence.variables)
    end
  end
end
