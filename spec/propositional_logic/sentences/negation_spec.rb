require 'spec_helper'

describe RuleRover::PropositionalLogic::Sentences::Negation do
  it 'does not raise' do
    expect { described_class.new(nil) }.not_to raise_error
  end

  describe '#de_moorgans_laws' do
    it 'returns a disjunction of negations' do
      sentence = sentence_factory.build(:not, ["a", :and, "b"])
      expects = sentence_factory.build(:not, "a", :or, :not, "b")

      expect(sentence.de_morgans_laws).to eq(expects)
    end

    it 'returns a conjunction of negations' do
      sentence = sentence_factory.build(:not, ["a", :or, "b"])
      expects = sentence_factory.build(:not, "a", :and, :not, "b")

      expect(sentence.de_morgans_laws).to eq(expects)
    end

    it 'ignores other sentence types' do
      sentence = sentence_factory.build(:not, ["a", :then, "b"])
      expect(sentence.de_morgans_laws).to eq(sentence)
    end
  end

  describe '#elim_double_negations' do
    it do
      sentence = sentence_factory.build(:not, [:not, "a"])
      expects = sentence_factory.build("a")
      expect(sentence.elim_double_negations).to eq(expects)
    end
    it do
      sentence = sentence_factory.build(:not, "a")
      expect(sentence.elim_double_negations).to eq(sentence)
    end
    it 'ignores non-atomic sentences' do
      sentence = sentence_factory.build(:not, [:not, ["a", :and, "b"]])
      expect(sentence.elim_double_negations).to eq(sentence)
    end
  end

  def sentence_factory
    RuleRover::PropositionalLogic::Sentences::Factory
  end
end