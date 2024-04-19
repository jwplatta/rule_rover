require 'spec_helper'

describe RuleRover::FirstOrderLogic::Sentences::PredicateSymbol do
  it 'does not raise' do
    expect { described_class.new(nil, nil) }.not_to raise_error
  end
  describe '.valid_name?' do
    context 'when name is valid' do
      it 'returns true for a symbol starting with a lowercase letter' do
        expect(described_class.valid_name?('Plato', :taught, 'Aristotle')).to be(true)
      end
    end
    context 'when name is invalid' do
      it 'returns false for a symbol starting with an uppercase letter' do
        expect(described_class.valid_name?('Plato', :Taught, 'Aristotle')).to be(false)
      end
      it 'returns false for a function name' do
        expect(described_class.valid_name?('Plato', :@taught, 'Aristotle')).to be(false)
      end
      it 'returns false for a string starting with an uppercase letter' do
        expect(described_class.valid_name?('Plato', "Taught", 'Aristotle')).to be(false)
      end
    end
  end
  describe '#initialize' do
    it do
      pred_sym = described_class.new('Socrates', :taught, 'Socrates', 'Alexander', 'Plotinus')
      expect(pred_sym.name).to eq(:taught)
      expect(pred_sym.subjects).to match_array(['Socrates'])
      expect(pred_sym.objects).to match_array(['Socrates', 'Alexander', 'Plotinus'])
      expect(pred_sym.vars).to match_array(['x_1', 'x_2', 'x_3'])
    end
  end
end