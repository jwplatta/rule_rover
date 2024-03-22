module RuleRover::PropositionalLogic::Algorithms
  class LogicAlgorithmBase
    class << self
      def run(kb: nil, query: [])
        self.new(kb, *query).entail?
      end
    end

    def initialize(kb, *query)
      @kb = kb
      @query = query
    end

    attr_reader :kb, :query

    def entail?
      raise NotImplementedError
    end

    private

    def sentence_factory
      RuleRover::PropositionalLogic::Sentences::Factory
    end
  end
end