module RuleRover::FirstOrderLogic
  CONNECTIVES=%i[and or then iff].freeze
  OPERATORS=%i[all some equals not and or then iff].freeze
  ENGINES=%i[matching forward_chaining backward_chaining].freeze
  QUANTIFIERS=%i[all some].freeze
end
