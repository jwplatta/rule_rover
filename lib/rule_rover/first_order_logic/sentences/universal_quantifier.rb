module RuleRover::FirstOrderLogic::Sentences
  class UniversalQuantifier < Quantifier
    def to_s
      ":all(#{vars.join(', ')}) [#{sentence}]"
    end
  end
end
