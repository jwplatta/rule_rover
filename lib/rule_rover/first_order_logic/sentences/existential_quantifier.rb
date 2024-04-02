module RuleRover::FirstOrderLogic::Sentences
  class ExistentialQuantifier
    def initialize(var, sentence)
      @var = var
      @sentence = sentence
    end

    attr_reader :var, :sentence

    def evaluate(model)
      raise NotImplementedError
    end

    def to_s
      ":some(#{var}) [#{sentence}]"
    end
  end
end