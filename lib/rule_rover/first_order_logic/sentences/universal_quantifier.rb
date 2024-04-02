module RuleRover::FirstOrderLogic::Sentences
  class UniversalQuantifier
    def initialize(var, sentence)
      @var = var
      @sentence = sentence
    end

    attr_reader :var, :sentence

    def evaluate(model)
      raise NotImplementedError
    end

    def to_s
      ":all(#{var}) [#{sentence}]"
    end
  end
end