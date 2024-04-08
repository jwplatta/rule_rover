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