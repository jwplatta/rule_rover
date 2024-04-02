module RuleRover::FirstOrderLogic::Sentences
  class UniversalQuantifier
    def initialize(vars, sentence)
      @vars = vars
      @sentence = sentence
    end

    attr_reader :vars, :sentence

    def evaluate(model)
      raise NotImplementedError
    end

    def to_s
      ":all(#{vars.join(', ')}) [#{sentence}]"
    end
  end
end