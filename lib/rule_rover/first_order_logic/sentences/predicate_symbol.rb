module RuleRover::FirstOrderLogic::Sentences
  class PredicateSymbol
    class << self
      def valid_name?(*args)
        name = args.find { |elm| elm.is_a? Symbol }
        !RuleRover::FirstOrderLogic::OPERATORS.include?(name) && /^[a-z]/.match?(name)
      end
    end

    def initialize(*args)
      name_index = args.find_index { |elm| elm.is_a? Symbol and /^[a-z]/.match?(elm) }
      # TODO: find which subjects and objects share the same name and make a list
      # of variables consistent with that naming
      if name_index
        @name = args[name_index]
        @subjects = args[0...name_index]
        @objects = args[(name_index + 1)...]
      end
    end

    # TODO:
    # def substitute(substitution={})
    #   self.class.new(
    #     *subjects.map { |subject| substitution[subject] || subject },
    #     name,
    #     *objects.map { |object| substitution[object] || object }
    #   )
    # end

    def evaluate(model)
      raise NotImplementedError
    end

    attr_reader :subjects, :name, :objects

    def to_s
      "[#{subjects.join(', ')} :#{name} #{objects.join(', ')}]"
    end
  end
end