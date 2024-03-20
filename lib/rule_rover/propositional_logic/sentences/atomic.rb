module RuleRover::PropositionalLogic::Sentences
  class Atomic < Sentence
    def initialize(sentence)
      @sentence = sentence
    end

    attr_reader :sentence

    def evaluate(model)
      model[sentence]
    end

    def ==(other)
      other.is_a? Atomic and sentence == other.sentence
    end

    def symbols
      Set.new([sentence])
    end

    def eliminate_biconditionals
      self
    end

    def eliminate_conditionals
      self
    end

    def elim_double_negations
      self
    end

    def de_morgans_laws
      self
    end

    def distribute
      self
    end

    def atoms
      [self]
    end

    def is_positive?
      true
    end

    def is_definite?
      true
    end

    def is_atomic?
      true
    end

    def to_s
      sentence
    end
  end
end

