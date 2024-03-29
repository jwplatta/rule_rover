module RuleRover::FirstOrderLogic::Sentences
  class PredicateSymbol
    class << self
      def valid_name?(name)
        name.is_a? Symbol and /^[a-z]/.match?(name.to_s)
      end
    end

    def initialize
    end
  end
end