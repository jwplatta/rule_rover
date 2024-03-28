require 'spec_helper'

describe RuleRover::FirstOrderLogic::Sentences::Factory do
  it 'does not raise' do
    expect { described_class.new }.not_to raise_error
  end

  xdescribe '.build' do
    describe 'when given a constant symbol' do
      it 'returns a ConstantSymbol object' do
        expect(described_class.build('Aristotle')).to be_a RuleRover::FirstOrderLogic::Sentences::ConstantSymbol
      end
    end
    describe 'when given a function symbol' do
      it 'returns a FunctionSymbol' do
        expect(described_class.build(:@teacher_of, 'Aristotle')).to be_a RuleRover::FirstOrderLogic::Sentences::PredicateSymbol
      end
    end
    describe 'when given a predicate symbol' do
      it 'returns a PredicateSymbol' do
        expect(described_class.build('Plato', :taught, 'Aristotle')).to be_a RuleRover::FirstOrderLogic::Sentences::PredicateSymbol
      end
    end
  end
end