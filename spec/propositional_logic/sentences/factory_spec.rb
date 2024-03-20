require 'spec_helper'

describe RuleRover::PropositionalLogic::Sentences::Factory do
  it 'does not raise' do
    expect { described_class.new }.not_to raise_error
  end

  describe '.wff?' do
    it 'returns false for bad formulas' do
      expect(described_class.wff?("a", :not)).to_not be true
      expect(described_class.wff?("a", :and)).to_not be true
      expect(described_class.wff?("a", :and, "b", :and, "c")).to_not be true
      expect(described_class.wff?("a", :not, :and, "b")).to_not be true
      expect(described_class.wff?(:iff)).to_not be true
    end

    it 'returns true for well formed formulas' do
      expect(described_class.wff?("a")).to be true
      expect(described_class.wff?(:not, "a")).to be true
      expect(described_class.wff?("a", :and, "b")).to be true
      expect(described_class.wff?("a", :or, "b")).to be true
      expect(described_class.wff?("a", :then, "b")).to be true
      expect(described_class.wff?("a", :iff, "b")).to be true
      expect(described_class.wff?(:not, ["a", :and, "b"])).to be true
      expect(described_class.wff?([["a", :and, "b"], :or, ["c", :and, :not, "d"]], :then, :not, "e")).to be true
      expect(described_class.wff?("c", :and, :not, "d")).to be true
      expect(described_class.wff?(:not, "c", :and, :not, "d")).to be true
    end
  end

  describe '.build' do
    it 'returns a atomic sentence' do
      expect(described_class.build("a")).to be_a(RuleRover::PropositionalLogic::Sentences::Atomic)
    end
    it 'returns a negation' do
      expect(described_class.build(:not, "a")).to be_a(RuleRover::PropositionalLogic::Sentences::Negation)
      expect(described_class.build(:not, ["a", :and, "b"])).to be_a(RuleRover::PropositionalLogic::Sentences::Negation)
    end
    it 'returns a conjunction' do
      expect(described_class.build("a", :and, "b")).to be_a(RuleRover::PropositionalLogic::Sentences::Conjunction)
      expect(described_class.build("a", :and, :not, "b")).to be_a(RuleRover::PropositionalLogic::Sentences::Conjunction)
    end
    it 'returns a disjunction' do
      expect(described_class.build("a", :or, "b")).to be_a(RuleRover::PropositionalLogic::Sentences::Disjunction)
      expect(described_class.build("a", :or, :not, "b")).to be_a(RuleRover::PropositionalLogic::Sentences::Disjunction)
      expect(described_class.build(["a", :and, "b"], :or, ["c", :and, "d"])).to be_a(RuleRover::PropositionalLogic::Sentences::Disjunction)

    end
    it 'returns a conditional' do
      expect(described_class.build("a", :then, "b")).to be_a(RuleRover::PropositionalLogic::Sentences::Conditional)
      expect(described_class.build("a", :then, :not, "b")).to be_a(RuleRover::PropositionalLogic::Sentences::Conditional)
      expect(described_class.build(["a", :or, "c"], :then, :not, "b")).to be_a(RuleRover::PropositionalLogic::Sentences::Conditional)
    end
    it 'returns a biconditional' do
      expect(described_class.build("a", :iff, "b")).to be_a(RuleRover::PropositionalLogic::Sentences::Biconditional)
      expect(described_class.build("a", :iff, :not, "b")).to be_a(RuleRover::PropositionalLogic::Sentences::Biconditional)
      expect(described_class.build(["a", :and, "c"], :iff, ["b", :then, "d"])).to be_a(RuleRover::PropositionalLogic::Sentences::Biconditional)
    end
  end
end