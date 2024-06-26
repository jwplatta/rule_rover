require "spec_helper"

describe RuleRover::PropositionalLogic::Sentences::Disjunction do
  it "does not raise" do
    expect { described_class.new(nil, nil) }.not_to raise_error
  end

  describe "#distribute" do
    describe "when both disjuncts are conjunctions" do
      it "returns a conjunction of disjunctions" do
        sentence = sentence_factory.build(["a", :and, "b"], :or, ["c", :and, "d"])
        expects = sentence_factory.build(["a", :or, ["c", :and, "d"]], :and, ["b", :or, ["c", :and, "d"]])
        expect(sentence.distribute).to eq(expects)
      end
    end
    describe "when only the left disjunct is a conjunction" do
      it "returns a conjunction of disjunctions" do
        sentence = sentence_factory.build(["a", :and, "b"], :or, "c")
        expects = sentence_factory.build(["a", :or, "c"], :and, ["b", :or, "c"])
        expect(sentence.distribute).to eq(expects)
      end
    end
    describe "when only the right disjunct is a conjunction" do
      it "returns a conjunction of disjunctions" do
        sentence = sentence_factory.build("a", :or, ["c", :and, "d"])
        expects = sentence_factory.build(["a", :or, "c"], :and, ["a", :or, "d"])
        expect(sentence.distribute).to eq(expects)
      end
    end
  end

  describe "#is_definite?" do
    it "returns true when there is exactly one positive disjunct" do
      sentence = sentence_factory.build(:not, "a", :or, ["b", :or, :not, "c"])
      expect(sentence.is_definite?).to be true
    end
    it "returns false when there is more than one positive disjunct" do
      sentence = sentence_factory.build("a", :or, ["b", :or, :not, "c"])
      expect(sentence.is_definite?).to be false
    end
    it "returns false when there is more than one positive disjunct" do
      sentence = sentence_factory.build("a", :or, "b", :or, "c")
      expect(sentence.is_definite?).to be false
    end
    it "returns false when there is no positive disjunct" do
      sentence = sentence_factory.build(:not, "a", :or, :not, "b")
      expect(sentence.is_definite?).to be false
    end
    it do
      sentence = sentence_factory.build(:not, "a", :or,
                                        [:not, "b", :or, [["d", :or, :not, "e"], :or, [:not, "f", :or, :not, "g"]]])
      expect(sentence.is_definite?).to be true
    end
  end

  describe "#premise_and_conclusion" do
    it "raises error" do
      # expect(sentence.premise_and_conclusion).to eq([["a", "b", "c"], "a"])
      expect do
        sentence_factory.build("a", :or,
                               ["b", :or, "c"]).premise_and_conclusion.premise_and_conclusion
      end.to raise_error(RuleRover::PropositionalLogic::Sentences::NotDefiniteClause)
    end
    it "returns the premise and conclusion" do
      sentence = sentence_factory.build(:not, "a", :or, [:not, "b", :or, "c"])
      expected_premises = [
        sentence_factory.build(:not, "a"),
        sentence_factory.build(:not, "b")
      ]
      expected_conlusion = sentence_factory.build("c")
      expected = [expected_premises, expected_conlusion]

      expect(sentence.premise_and_conclusion).to eq(expected)
    end
  end

  def sentence_factory
    RuleRover::PropositionalLogic::Sentences::Factory
  end
end
