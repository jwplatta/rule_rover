require 'spec_helper'

describe RuleRover::FirstOrderLogic::Sentences::PredicateSymbol do
  it 'does not raise' do
    expect { described_class.new }.not_to raise_error
  end
  describe '.valid_name?' do
    it 'returns true for a symbol starting with a lowercase letter' do
      expect(described_class.valid_name?(:taught)).to be(true)
    end
    it 'returns false for a symbol starting with an uppercase letter' do
      expect(described_class.valid_name?(:Taught)).to be(false)
    end
    it 'returns false for a function name' do
      expect(described_class.valid_name?(:@taught)).to be(false)
    end
    it 'returns false for a string starting with an uppercase letter' do
      expect(described_class.valid_name?("Taught")).to be(false)
    end
  end
end