module RuleRover
  module BooleanMonkeyPatch
    def ⊃(other)
      not(self) or other
    end

    def ≡(other)
      (self.⊃ other) and (other.⊃ self)
    end
  end
end

TrueClass.include RuleRover::BooleanMonkeyPatch
FalseClass.include RuleRover::BooleanMonkeyPatch
