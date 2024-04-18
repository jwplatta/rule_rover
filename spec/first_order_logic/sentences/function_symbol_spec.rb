require 'spec_helper'

describe RuleRover::FirstOrderLogic::Sentences::FunctionSymbol do
  it 'does not raise' do
    expect { described_class.new }.not_to raise_error
  end

  describe '.valid_name?' do
    it 'returns true for a symbol starting with an @' do
      expect(described_class.valid_name?(:@teacher_of, 'Aristotle')).to be(true)
    end
    it 'returns false for a predicate name' do
      expect(described_class.valid_name?(:teacher_of, 'Aristotle')).to be(false)
    end
    it 'returns false for a string' do
      expect(described_class.valid_name?("@teacher_of", 'Aristotle')).to be(false)
    end
  end
  describe '#initialize' do
    it do
      func_sym = described_class.new(:@teacher_of, 'Aristotle')
      expect(func_sym.name).to eq(:@teacher_of)
      expect(func_sym.args).to match_array(['Aristotle'])
      expect(func_sym.vars).to match_array(['x_1'])
    end
  end
end