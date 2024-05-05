require_relative '../standardize_apart'

module RuleRover::FirstOrderLogic::Sentences
  include RuleRover::FirstOrderLogic::StandardizeApart

  class FunctionSymbol
    class << self
      def valid_name?(*args)
        args.any? { |elm| elm.is_a? Symbol and /^@/.match?(elm) }
      end
    end

    def initialize(name:, args: [])
      @name = name
      @args = args
    end

    attr_reader :name, :args

    def constants
      Set.new(args.select { |arg| arg.is_a? ConstantSymbol })
    end

    def is_term?
      true
    end

    def ==(other)
      standardize.to_s == other.standardize.to_s
    end

    def standardize
      transform(self)
    end

    def eql?(other)
      self == other
    end

    def hash
      to_s.hash
    end

    def to_s
      "[:#{name} #{args.join(', ')}]"
    end
  end
end
