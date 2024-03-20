require 'spec_helper'

describe RuleRover::PropositionalLogic::Sentences::Conditional do
  Factory = RuleRover::PropositionalLogic::Sentences::Factory
  it 'does not raise' do
    expect { described_class.new(nil, nil) }.not_to raise_error
  end

  describe '#eliminate_conditionals' do
    it 'returns a disjunction with antecedent negated' do
      sentence = Factory.build("a", :then, "b")
      expects = Factory.build(:not, "a", :or, "b")
      expect(sentence.eliminate_conditionals).to eq(expects)
    end
  end
end