module RuleRover::FirstOrderLogic::Sentences
  class Biconditional < ComplexSentence
    def evaluate(model)
      left.evaluate(model) == right.evaluate(model)
    end

    def eliminate_biconditionals
      Conjunction.new(
        Conditional.new(left.eliminate_biconditionals, right.eliminate_biconditionals),
        Conditional.new(right.eliminate_biconditionals, left.eliminate_biconditionals)
      )
    end

    def to_s
      "[#{left} :iff #{right}]"
    end
  end
end
