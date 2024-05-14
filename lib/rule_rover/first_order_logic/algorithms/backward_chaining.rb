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
      end

      def backward_chain(kb, query)
      end
    end
  end
end
