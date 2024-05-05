require_relative '../substitution'

module RuleRover::FirstOrderLogic::Sentences
  class UniversalQuantifier
    include RuleRover::FirstOrderLogic::Substitution

    def initialize(vars, sentence)
      @vars = vars
      @sentence = sentence
    end

    attr_reader :vars, :sentence

    def constants
      sentence.constants
    end

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
      ":all(#{vars.join(', ')}) [#{sentence}]"
    end
  end
end
