module RuleRover::FirstOrderLogic::Sentences
  class Negation
    def initialize(sentence_or_term)
      @sentence = sentence_or_term
    end

    attr_reader :sentence

    def constants
      sentence.constants
    end


    def evaluate(model)
      not sentence.evaluate(model)
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
      "[:not #{sentence}]"
    end

    # def symbol
    #   if is_atomic?
    #     sentence.symbol
    #   else
    #     raise SentenceNotInCNF.new
    #   end
    # end

    # def symbols
    #   sentence.symbols
    # end

    # def atoms
    #   if is_atomic?
    #     Set.new([self])
    #   else
    #     sentence.atoms
    #   end
    # end

    # def eliminate_biconditionals
    #   Negation.new(sentence.eliminate_biconditionals)
    # end

    # def eliminate_conditionals
    #   Negation.new(sentence.eliminate_conditionals)
    # end

    # def distribute
    #   self
    # end

    # def elim_double_negations
    #   if sentence.is_a? self.class and sentence.sentence.is_atomic?
    #     sentence.sentence
    #   else
    #     Negation.new(sentence.elim_double_negations)
    #   end
    # end

    # def de_morgans_laws
    #   if sentence.is_a? Conjunction
    #     Disjunction.new(
    #       Negation.new(sentence.left),
    #       Negation.new(sentence.right)
    #     )
    #   elsif sentence.is_a? Disjunction
    #     Conjunction.new(
    #       Negation.new(sentence.left),
    #       Negation.new(sentence.right)
    #     )
    #   else
    #     Negation.new(sentence.de_morgans_laws)
    #   end
    # end

    # def is_atomic?
    #   sentence.is_atomic?
    # end
  end
end