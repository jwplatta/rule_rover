require_relative '../sentences/unification'

module RuleRover::FirstOrderLogic
  module Algorithms
    class QueryNotAtomicSentence < StandardError; end
    class BackwardChaining
      include RuleRover::FirstOrderLogic::Sentences::Unification

      class << self
        def backward_chain(kb, query)
          self.new(kb, query).backward_chain(kb, query)
        end
      end

      def initialize(kb, query)
        @kb = kb
        @query = query
      end

      attr_reader :kb, :query

      def backward_chain(kb, query)
      end
    end
  end
end
