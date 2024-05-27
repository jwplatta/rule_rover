module RuleRover::PropositionalLogic::Sentences
  class Negation < Sentence
    def initialize(sentence)
      @sentence = sentence
    end

    attr_reader :sentence

    def symbol
      raise SentenceNotInCNF.new unless is_atomic?

      sentence.symbol
    end

    def evaluate(model)
      !sentence.evaluate(model)
    end

    def symbols
      sentence.symbols
    end

    def atoms
      if is_atomic?
        Set.new([self])
      else
        sentence.atoms
      end
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

    def is_atomic?
      sentence.is_atomic?
    end

    def to_s
      "[:not #{sentence}]"
    end
  end
end
