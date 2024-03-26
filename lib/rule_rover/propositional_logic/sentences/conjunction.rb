module RuleRover::PropositionalLogic::Sentences
  class Conjunction < Sentence
    def evaluate(model)
      left.evaluate(model) and right.evaluate(model)
    end

    def to_s
      "[#{left} :and #{right}]"
    end
  end
end