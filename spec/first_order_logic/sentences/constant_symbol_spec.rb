require 'spec_helper'

describe RuleRover::FirstOrderLogic::Sentences::ConstantSymbol do
  it 'does not raise' do
    expect { described_class.new('Aristotle') }.not_to raise_error
  end

  describe '.valid_name?' do
    it 'returns true for a string starting with a capital letter' do
      expect(described_class.valid_name?('Aristotle')).to be(true)
    end
    it 'returns false for a string starting with a lowercase letter' do
      expect(described_class.valid_name?('aristotle')).to be(false)
    end
  end
end