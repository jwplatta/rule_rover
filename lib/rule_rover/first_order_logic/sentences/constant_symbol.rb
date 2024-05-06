require_relative 'substitution'

module RuleRover::FirstOrderLogic::Sentences
  class ConstantSymbol
    include Expression

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

    def to_s
      name
    end
  end
end
