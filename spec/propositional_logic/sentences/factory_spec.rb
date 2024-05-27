require "spec_helper"

describe RuleRover::PropositionalLogic::Sentences::Factory do
  it "does not raise" do
    expect { described_class.new }.not_to raise_error
  end

  describe ".build" do
    it "returns a atomic sentence" do
      expect(described_class.build("a")).to be_a(RuleRover::PropositionalLogic::Sentences::Atomic)
    end
    it "returns a negation" do
      expect(described_class.build(:not, "a")).to be_a(RuleRover::PropositionalLogic::Sentences::Negation)
      expect(described_class.build(:not, ["a", :and, "b"])).to be_a(RuleRover::PropositionalLogic::Sentences::Negation)
    end
    it "returns a conjunction" do
      expect(described_class.build("a", :and, "b")).to be_a(RuleRover::PropositionalLogic::Sentences::Conjunction)
      expect(described_class.build("a", :and, :not, "b")).to be_a(RuleRover::PropositionalLogic::Sentences::Conjunction)
    end
    it "returns a disjunction" do
      expect(described_class.build("a", :or, "b")).to be_a(RuleRover::PropositionalLogic::Sentences::Disjunction)
      expect(described_class.build("a", :or, :not, "b")).to be_a(RuleRover::PropositionalLogic::Sentences::Disjunction)
      expect(described_class.build(["a", :and, "b"], :or,
                                   ["c", :and, "d"])).to be_a(RuleRover::PropositionalLogic::Sentences::Disjunction)
    end
    it "returns a conditional" do
      expect(described_class.build("a", :then, "b")).to be_a(RuleRover::PropositionalLogic::Sentences::Conditional)
      expect(described_class.build("a", :then, :not,
                                   "b")).to be_a(RuleRover::PropositionalLogic::Sentences::Conditional)
      expect(described_class.build(["a", :or, "c"], :then, :not,
                                   "b")).to be_a(RuleRover::PropositionalLogic::Sentences::Conditional)
    end
    it "returns a biconditional" do
      expect(described_class.build("a", :iff, "b")).to be_a(RuleRover::PropositionalLogic::Sentences::Biconditional)
      expect(described_class.build("a", :iff, :not,
                                   "b")).to be_a(RuleRover::PropositionalLogic::Sentences::Biconditional)
      expect(described_class.build(["a", :and, "c"], :iff,
                                   ["b", :then, "d"])).to be_a(RuleRover::PropositionalLogic::Sentences::Biconditional)
    end
    it do
      expect(described_class.build(:not, "a", :or,
                                   ["b", :or, :not, "c"])).to be_a(RuleRover::PropositionalLogic::Sentences::Disjunction)
    end
  end
end
