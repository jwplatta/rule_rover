module RuleRover::FirstOrderLogic::Sentences
  class Disjunction < ComplexSentence
    def evaluate(model)
      left.evaluate(model) or right.evaluate(model)
    end

    def to_s
      "[#{left} :or #{right}]"
    end
  end
end
