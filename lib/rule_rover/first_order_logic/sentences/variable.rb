module RuleRover::FirstOrderLogic::Sentences
  class Variable
    include Substitution

    class << self
      def valid_name?(name)
        name.is_a? String and /\A[a-z]/.match?(name)
      end
    end

    def initialize(name)
      self.class.valid_name?(name) or raise ArgumentError, "Invalid variable name: #{name}"

      @name = name
    end

    def constants
      Set.new([])
    end

    attr_reader :name

    def ==(other)
      to_s == other.to_s
    end

    def eql?(other)
      self == other
    end

    def hash
      to_s.hash
    end

    def to_s
      name
    end
  end
end
