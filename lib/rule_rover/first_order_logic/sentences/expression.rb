require_relative 'substitution'
require_relative 'standardize_apart'

module RuleRover::FirstOrderLogic::Sentences
  module Expression
    include Substitution
    include StandardizeApart

    # def ==(other)
    #   standardize.to_s == other.standardize.to_s
    # end

    # def standardize
    #   standardize_apart(self)
    # end

    def ==(other)
      to_s == other.to_s
    end

    def eql?(other)
      self == other
    end

    def hash
      to_s.hash
    end

    def evaluate(model)
      raise NotImplementedError
    end

    def to_s
      raise NotImplementedError
    end
  end
end
