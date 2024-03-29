module RuleRover::FirstOrderLogic::Sentences
  class FunctionSymbol
    class << self
      def valid?(name)
        name.is_a? Symbol and /^@/.match?(name.to_s)
      end
    end

    def initialize
    end
  end
end