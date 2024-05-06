module RuleRover::FirstOrderLogic::Sentences
  class PredicateSymbol
    include StandardizeApart
    include Substitution

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

    def is_term?
      true
    end

    def evaluate(model)
      raise NotImplementedError
    end

    def ==(other)
      standardize.to_s == other.standardize.to_s
    end

    def standardize
      transform(self)
    end

    def eql?(other)
      self == other
    end

    def hash
      to_s.hash
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
