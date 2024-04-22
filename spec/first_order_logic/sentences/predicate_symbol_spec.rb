require 'spec_helper'

describe RuleRover::FirstOrderLogic::Sentences::PredicateSymbol do
  it 'does not raise' do
    expect { described_class.new(name: nil, subjects: [], objects: []) }.not_to raise_error
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
      pred_sym = sentence_factory.build('Socrates', :taught, 'Socrates', 'Alexander', 'Plotinus')
      socrates = sentence_factory.build('Socrates')
      alexander = sentence_factory.build('Alexander')
      plotinus = sentence_factory.build('Plotinus')
      expect(pred_sym.name).to eq(:taught)
      expect(pred_sym.subjects).to match_array([socrates])
      expect(pred_sym.objects).to match_array([socrates, alexander, plotinus])
    end
  end

  def sentence_factory
    RuleRover::FirstOrderLogic::Sentences::Factory
  end
end