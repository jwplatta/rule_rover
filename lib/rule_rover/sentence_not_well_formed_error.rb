module RuleRover
  class SentenceNotWellFormedError < StandardError
    def initialize(message = "Sentence is not a well-formed formula.")
      super(message)
    end
  end
end