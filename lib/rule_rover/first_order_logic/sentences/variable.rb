module RuleRover::FirstOrderLogic::Sentences
  class Variable
    class << self
      def valid_name?(name)
        name.is_a? String and /^[a-z]/.match?(name)
      end
    end

    def initialize(name)
      @name = name
    end
    attr_reader :name

    def to_s
      name
    end
  end
end