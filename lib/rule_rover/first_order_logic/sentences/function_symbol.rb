module RuleRover::FirstOrderLogic::Sentences
  class FunctionSymbol
    class << self
      def valid_name?(*args)
        args.any? { |elm| elm.is_a? Symbol and /^@/.match?(elm) }
      end
    end

    def initialize(*args)
      # TODO: find vars consistent with constant names
      @name = args.find { |elm| elm.is_a? Symbol and /^@/.match?(elm) }
      @args = args.select { |elm| not(/^@/.match?(elm)) }
      @vars = @args.uniq.each_with_index.map do |arg, index|
        "x_#{index+1}"
      end
    end

    attr_reader :name, :args, :vars

    def to_s
      "[:#{name} #{args.join(', ')}]"
    end
  end
end