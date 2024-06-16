require_relative "substitution"
require_relative "standardize_apart"

module RuleRover::FirstOrderLogic::Sentences
  module Expression
    include Substitution
    include StandardizeApart

    def ==(other)
      standardize_apart(self, reset: true).to_s == standardize_apart(other, reset: true).to_s
    end

    def eql?(other)
      self == other
    end

    def hash
      to_s.hash
    end

    def lifted?
      raise NotImplementedError
    end

    def grounded?
      raise NotImplementedError
    end

    def evaluate(model)
      raise NotImplementedError
    end

    def constants
      raise NotImplementedError
    end

    def variables
      raise NotImplementedError
    end

    def to_s
      raise NotImplementedError
    end

    # def self.included(base)
    #   if base.instance_methods.include?(:left)
    #     base.include(MultipleTerms)
    #   elsif base.instance_methods.include?(:vars)
    #     base.include(SingleTerm)
    #   end
    # end

    # module MultipleTerms
    #   def constants
    #     left.constants.merge(right.constants)
    #   end

    #   def variables
    #     left.variables.merge(right.variables)
    #   end
    # end

    # module Quantifier
    #   def initialize(vars, sentence)
    #     @vars = vars
    #     @sentence = sentence
    #   end

    #   attr_reader :vars, :sentence

    #   def constants
    #     sentence.constants
    #   end
    # end
  end
end
