require 'spec_helper'

describe RuleRover::FirstOrderLogic::Sentences::FunctionSymbol do
  it 'does not raise' do
    expect { described_class.new }.not_to raise_error
  end

  describe '.valid?' do
    it 'returns true for a symbol starting with an @' do
      expect(described_class.valid?(:@teacher_of)).to be(true)
    end
    it 'returns false for a symbol starting with a letter' do
      expect(described_class.valid?(:teacher_of)).to be(false)
    end
    it 'returns false for a string' do
      expect(described_class.valid?("@teacher_of")).to be(false)
    end
  end
end