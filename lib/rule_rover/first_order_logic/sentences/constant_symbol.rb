require_relative 'substitution'

module RuleRover::FirstOrderLogic::Sentences
  class ConstantSymbol
    include Substitution

    class << self
      def valid_name?(name)
        name.is_a? String and /\A[A-Z][a-z0-9]*\z/.match?(name.to_s)
      end
    end

    def initialize(name)
      @name = name
    end

    attr_reader :name

    def constants
      Set.new([self])
    end

    # NOTE: consider creating a SymbolBase class that
    # implements the #==, #eql?, #hash, and #to_s methods
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
