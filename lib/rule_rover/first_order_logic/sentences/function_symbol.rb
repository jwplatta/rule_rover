module RuleRover::FirstOrderLogic::Sentences
  class FunctionSymbol
    include Expression

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

    def variables
      Set.new(args.select { |arg| arg.is_a? Variable })
    end

    def to_s
      "[:#{name} #{args.join(", ")}]"
    end
  end
end
