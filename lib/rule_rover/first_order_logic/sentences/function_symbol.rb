module RuleRover::FirstOrderLogic::Sentences
  class FunctionSymbol
    class << self
      def valid_name?(*args)
        args.find do |elm|
          elm.is_a? Symbol and /^@/.match?(elm)
        end
      end
    end

    def initialize(*args)
      @name = args.find { |elm| elm.is_a? Symbol and /^@/.match?(elm) }
      @args = args.select { |elm| not(/^@/.match?(elm)) }
    end

    attr_reader :name, :args

    def to_s
      "[:#{name} #{args.join(', ')}]"
    end
  end
end