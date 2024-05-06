require 'spec_helper'

describe RuleRover::FirstOrderLogic::Sentences::ConstantSymbol do
  it 'does not raise' do
    expect { described_class.new('Aristotle') }.not_to raise_error
  end

  describe '.valid_name?' do
    context 'when valid name' do
      it 'returns true for a string starting with a capital letter' do
        expect(described_class.valid_name?('Aristotle')).to be(true)
        expect(described_class.valid_name?('Aristotle1')).to be(true)
      end
    end
    context 'when invalid name' do
      it 'returns false for a string starting with a lowercase letter' do
        expect(described_class.valid_name?('aristotle')).to be(false)
      end
      it 'returns false for a string without non-alphanumeric' do
        expect(described_class.valid_name?('Aristotle$')).to be(false)
        expect(described_class.valid_name?('Aristotle@')).to be(false)
      end
    end
  end
end