module RuleRover::FirstOrderLogic::Sentences
  class PredicateSymbol
    class << self
      def valid_name?(*args)
        name = args.find { |elm| elm.is_a? Symbol }
        /^[a-z]/.match?(name.to_s)
      end
    end

    def initialize(*args)
      name_index = args.find_index { |elm| elm.is_a? Symbol }
      if name_index
        @name = args[name_index]
        @subjects = args[0...name_index]
        @objects = args[(name_index + 1)...]
      end
    end

    attr_reader :subjects, :name, :objects
  end
end