module RuleRover::FirstOrderLogic::Sentences
  class ExistentialQuantifier < Quantifier
    def to_s
      ":some(#{vars.join(", ")}) [#{sentence}]"
    end
  end
end
