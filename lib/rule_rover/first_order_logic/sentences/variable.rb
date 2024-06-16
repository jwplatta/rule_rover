module RuleRover::FirstOrderLogic::Sentences
  class Variable
    include Expression

    class << self
      def valid_name?(name)
        name.is_a? String and /\A[a-z]/.match?(name)
      end
    end

    def initialize(name)
      self.class.valid_name?(name) or raise ArgumentError, "Invalid variable name: #{name}"

      @name = name
    end

    attr_reader :name

    def grounded?
      false
    end

    def constants
      Set.new([])
    end

    def variables
      Set.new([self])
    end

    def to_s
      name
    end
  end
end
