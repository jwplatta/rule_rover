require 'spec_helper'

describe RuleRover::PropositionalLogic::Sentences::Conditional do
  it 'does not raise' do
    expect { described_class.new(nil, nil) }.not_to raise_error
  end

  describe '#eliminate_conditionals' do
    it 'returns a disjunction with antecedent negated' do
      sentence = sentence_factory.build("a", :then, "b")
      expects = sentence_factory.build(:not, "a", :or, "b")
      expect(sentence.eliminate_conditionals).to eq(expects)
    end
  end

  def sentence_factory
    RuleRover::PropositionalLogic::Sentences::Factory
  end
end