module RuleRover::FirstOrderLogic::Sentences
  class PredicateSymbol
    class << self
      def valid_name?(*args)
        name = args.find { |elm| elm.is_a? Symbol }
        !RuleRover::FirstOrderLogic::OPERATORS.include?(name) && /^[a-z]/.match?(name)
      end
    end

    def initialize(name:, subjects: [], objects: [])
      @name = name
      @subjects = subjects
      @objects = objects
      @vars = standardize_apart
      # name_index = args.find_index { |elm| elm.is_a? Symbol and /^[a-z]/.match?(elm) }

      # if name_index
      #   @name = args[name_index]
      #   @subjects = args[0...name_index]
      #   @objects = args[(name_index + 1)...]
      #   @vars = @subjects.dup.concat(@objects).uniq.each_with_index.map do |arg, index|
      #     "x_#{index+1}"
      #   end
      # end
    end

    def standardize_apart
      subjects.dup.concat(objects).uniq.each_with_index.inject({}) do |hash, (arg, index)|
        hash[arg] = sentence_factory.build("x_#{index+1}")
        hash
      end
    end

    attr_reader :subjects, :name, :objects, :vars

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

    def to_s
      "[#{subjects.join(', ')} :#{name} #{objects.join(', ')}]"
    end

    private

    def sentence_factory
      RuleRover::FirstOrderLogic::Sentences::Factory
    end
  end
end
