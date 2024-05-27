require "spec_helper"

describe RuleRover::PropositionalLogic::Sentences::Biconditional do
  it "does not raise" do
    expect { described_class.new(nil, nil) }.not_to raise_error
  end

  describe "#eliminate_biconditionals" do
    it "returns a conjunction of conditionals" do
      sentence = sentence_factory.build("a", :iff, "b")
      expects = sentence_factory.build(["a", :then, "b"], :and, ["b", :then, "a"])
      expect(sentence.eliminate_biconditionals).to eq(expects)
    end
  end

  def sentence_factory
    RuleRover::PropositionalLogic::Sentences::Factory
  end
end
