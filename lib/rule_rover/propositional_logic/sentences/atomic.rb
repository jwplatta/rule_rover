module RuleRover::PropositionalLogic::Sentences
  class NotInModel < StandardError; end

  class Atomic < Sentence
    def initialize(symbol)
      @symbol = symbol
    end

    attr_reader :symbol

    def sentence
      @symbol
    end

    def evaluate(model)
      model.fetch(symbol, false)
    end

    def in_model?(model)
      model.include?(symbol)
    end

    def ==(other)
      other.is_a? Atomic and sentence == other.sentence
    end

    def symbols
      Set.new([symbol])
    end

    def atoms
      Set.new([self])
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
