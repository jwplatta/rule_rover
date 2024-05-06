require_relative 'standardize_apart'
require_relative 'substitution'

module RuleRover::FirstOrderLogic::Sentences
  class FunctionSymbol
    include StandardizeApart
    include Substitution

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

    def ==(other)
      standardize.to_s == other.standardize.to_s
    end

    def standardize
      standardize_apart(self)
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
