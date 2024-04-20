module RuleRover::FirstOrderLogic::Sentences
  class FunctionSymbol
    class << self
      def valid_name?(*args)
        args.any? { |elm| elm.is_a? Symbol and /^@/.match?(elm) }
      end
    end

    def initialize(name, args)
      @name = name
      @args = args
      @vars = standardize_apart
    end

    attr_reader :name, :args, :vars

    def standardize_apart
      args.uniq.each_with_index.inject({}) do |hash, (arg, index)|
        hash[arg] = sentence_factory.build("x_#{index+1}")
        hash
      end
    end

    def to_s
      "[:#{name} #{args.join(', ')}]"
    end

    private

    def sentence_factory
      RuleRover::FirstOrderLogic::Sentences::Factory
    end
  end
end
