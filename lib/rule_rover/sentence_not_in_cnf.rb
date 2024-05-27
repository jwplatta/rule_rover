class RuleRover::SentenceNotInCNF < StandardError
  def initialize(message = "Sentence is not conjunctive normal form.")
    super(message)
  end
end
