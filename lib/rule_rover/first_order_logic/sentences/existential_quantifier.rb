module RuleRover::FirstOrderLogic::Sentences
  class ExistentialQuantifier
    def initialize(vars, sentence)
      @vars = vars
      @sentence = sentence
    end

    attr_reader :vars, :sentence

    def evaluate(model)
      raise NotImplementedError
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
      ":some(#{vars.join(', ')}) [#{sentence}]"
    end
  end
end