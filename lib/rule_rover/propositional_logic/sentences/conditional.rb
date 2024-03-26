module RuleRover::PropositionalLogic::Sentences
  class Conditional < Sentence
    def evaluate(model)
      not left.evaluate(model) or right.evaluate(model)
    end

    def eliminate_conditionals
      Disjunction.new(
        Negation.new(left.eliminate_conditionals),
        right.eliminate_conditionals
      )
    end

    def to_s
      "[#{left} :then #{right}]"
    end
  end
end
