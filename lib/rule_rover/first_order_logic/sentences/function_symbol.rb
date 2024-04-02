module RuleRover::FirstOrderLogic::Sentences
  class FunctionSymbol
    class << self
      def valid_name?(*args)
        name = args.find { |elm| elm.is_a? Symbol }
        /^@/.match?(name)
      end
    end

    def initialize(*args)
      @name = args.find { |elm| elm.is_a? Symbol }
      @args = args.select { |elm| elm.is_a? String }
    end

    attr_reader :name, :args

    def to_s
      "[:#{name} #{args.join(', ')}]"
    end
  end
end