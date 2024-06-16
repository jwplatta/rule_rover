module RuleRover::FirstOrderLogic::Sentences
  # The ComplexSentence class defines an interface for representing expressions that consist
  # of more than one term. Instances of this class hold references to these sub-expressions,
  # typically denoted as the left and right parts of the complex sentence.
  #
  # == Attributes
  #
  # [left]  Represents the left sub-expression of the complex sentence.
  # [right] Represents the right sub-expression of the complex sentence.
  #
  class ComplexSentence
    include Expression

    def initialize(left, right)
      @left = left
      @right = right
    end

    attr_reader :left, :right

    def grounded?
      left.grounded? && right.grounded?
    end

    def constants
      left.constants.merge(right.constants)
    end

    def variables
      left.variables.merge(right.variables)
    end
  end
end
