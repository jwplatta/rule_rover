require 'spec_helper'

describe RuleRover::PropositionalLogic::KnowledgeBase do
  it 'does not raise' do
    expect { described_class.new }.not_to raise_error
  end
  describe '#connectives' do
    it do
      expect(subject.connectives).to eq RuleRover::CONNECTIVES
    end
  end
  describe '#operators' do
    it do
      expect(subject.operators).to eq RuleRover::OPERATORS
    end
  end
  describe '#assert' do
    it 'it saves a set of sentences' do
      subject.assert("a", :and, "b")
      subject.assert("a", :and, "b")
      expect(subject.sentences.size).to eq 1
    end
    it 'saves a set of symbols' do
      subject.assert("a", :and, "b")
      subject.assert("a", :or, "c")
      subject.assert("d", :then, "b")
      expect(subject.symbols).to eq(Set.new(["a", "b", "c", "d"]))
    end
  end
end