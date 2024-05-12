module RuleRover::FirstOrderLogic::Sentences
  class PredicateSymbol
    include Expression

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
    end

    attr_reader :name, :subjects, :objects

    def constants
      Set.new(
        subjects.select { |arg| arg.is_a? ConstantSymbol } +
        objects.select { |arg| arg.is_a? ConstantSymbol }
      )
    end

    def variables
      Set.new(
        subjects.select { |arg| arg.is_a? Variable } +
        objects.select { |arg| arg.is_a? Variable }
      )
    end

    def to_s
      "[#{subjects.join(', ')} :#{name} #{objects.join(', ')}]"
    end
  end
end
