module RuleRover::PropositionalLogic::Sentences
  class Negation < Sentence
    def initialize(sentence)
      @sentence = sentence
    end

    attr_reader :sentence

    def evaluate(model)
      not sentence.evaluate(model)
    end

    def symbols
      Set.new(sentence.symbols)
    end

    def eliminate_biconditionals
      Negation.new(sentence.eliminate_biconditionals)
    end

    def eliminate_conditionals
      Negation.new(sentence.eliminate_conditionals)
    end

    def distribute
      self
    end

    def elim_double_negations
      if sentence.is_a? self.class and sentence.sentence.is_atomic?
        sentence.sentence
      else
        Negation.new(sentence.elim_double_negations)
      end
    end

    def de_morgans_laws
      if sentence.is_a? Conjunction
        Disjunction.new(
          Negation.new(sentence.left),
          Negation.new(sentence.right)
        )
      elsif sentence.is_a? Disjunction
        Conjunction.new(
          Negation.new(sentence.left),
          Negation.new(sentence.right)
        )
      else
        Negation.new(sentence.de_morgans_laws)
      end
    end

    def is_positive?
      false
    end

    def is_atomic?
      sentence.is_atomic?
    end

    def atoms
      if is_atomic?
        [self]
      else
        sentence.atoms
      end
    end

    def to_s
      "[:not #{sentence}]"
    end
  end
end