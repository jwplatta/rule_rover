require_relative "substitution"

module RuleRover::FirstOrderLogic::Sentences
  class ConstantSymbol
    include Expression

    class << self
      def valid_name?(name)
        if name.is_a? String
          /\A[A-Z][a-z0-9]*\z/.match?(name.to_s)
        else
          # NOTE: all other types are valid. Should exclude datatypes from RuleRover.
          true
        end
      end
    end

    def initialize(name)
      @name = name
      @type = name.class
    end

    attr_reader :name, :type

    def value
      name
    end

    def constants
      Set.new([self])
    end

    def variables
      Set.new([])
    end

    def to_s
      name
    end
  end
end
