# NOTE: must start with a capital letter
module RuleRover::FirstOrderLogic::Sentences
  class ConstantSymbol
    class << self
      def valid_name?(name)
        name.is_a? String and /^[A-Z]/.match?(name.to_s)
      end
    end

    def initialize(name)
      @name = name
    end
    attr_reader :name
  end
end