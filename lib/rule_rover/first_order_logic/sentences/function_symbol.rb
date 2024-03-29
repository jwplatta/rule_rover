module RuleRover::FirstOrderLogic::Sentences
  class FunctionSymbol
    class << self
      def valid_name?(name)
        name.is_a? Symbol and /^@/.match?(name.to_s)
      end
    end

    def initialize
    end
  end
end