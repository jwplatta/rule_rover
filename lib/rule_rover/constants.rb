module RuleRover
  CONNECTIVES=%i[and or then iff].freeze
  OPERATORS=%i[not and or then iff].freeze
  ENGINES=%i[model_checking resolution forward_chaining backward_chaining].freeze
  QUANTIFIERS=%i[all some].freeze
end
