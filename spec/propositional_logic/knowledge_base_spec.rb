require 'spec_helper'

describe PropositionalLogic::KnowledgeBase do
  it 'does not raise' do
    expect { PropositionalLogic::KnowledgeBase.new }.not_to raise_error
  end
  describe 'wff?' do
    it 'returns true for atomic sentences' do
      expect(subject.wff?('A')).to be true
      expect(subject.wff?('a')).to be true
      expect(subject.wff?('Peter Pan')).to be true
      expect(subject.wff?(:xyz)).not_to be true
    end

    it 'returns true for negated atomic sentences' do
      expect(subject.wff?(:not, "a")).to be true
      expect(subject.wff?(:not, "A")).to be true
      expect(subject.wff?(:not, "Peter Pan")).to be true
      expect(subject.wff?("A", :not, "Peter Pan")).not_to be true
    end

    it 'returns true for conjunctions' do
      expect(subject.wff?("A", :and, "B")).to be true
      expect(subject.wff?(["A", :and, "B"], :and, "C")).to be true
      expect(subject.wff?([:and, "A", "B"], :and, "C")).not_to be true
    end

    it 'returns true for disjunctions' do
      expect(subject.wff?("A", :or, "B")).to be true
      expect(subject.wff?(["A", :or, "B"], :or, "C")).to be true
      expect(subject.wff?([:or, "A", "B"], :or, "C")).not_to be true
    end

    it 'returns true for conditionals' do
      expect(subject.wff?("A", :then, "B")).to be true
      expect(subject.wff?(["A", :then, "B"], :then, "C")).to be true
      expect(subject.wff?([:then, "A", "B"], :then, "C")).not_to be true
    end

    it 'returns true for biconditionals' do
      expect(subject.wff?("A", :iff, "B")).to be true
      expect(subject.wff?(["A", :iff, "B"], :iff, "C")).to be true
      expect(subject.wff?([:iff, "A", "B"], :iff, "C")).not_to be true
    end
  end
end