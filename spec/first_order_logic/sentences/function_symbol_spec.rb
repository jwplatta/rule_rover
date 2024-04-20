require 'spec_helper'

describe RuleRover::FirstOrderLogic::Sentences::FunctionSymbol do
  it 'does not raise' do
    expect { described_class.new(nil, []) }.not_to raise_error
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
      func_sym = sentence_factory.build(:@teacher_of, 'Aristotle')
      expect(func_sym.name).to eq(:@teacher_of)
      expect(func_sym.args).to match_array([sentence_factory.build('Aristotle')])
      expect(func_sym.vars).to eq(
        {
          sentence_factory.build('Aristotle') => sentence_factory.build('x_1')
        }
      )
    end
  end

  describe '#standardize_apart' do
    it do
      func_sym = sentence_factory.build(:@son_of, 'Peter', 'a')
      expected = {
        sentence_factory.build('Peter') => sentence_factory.build('x_1'),
        sentence_factory.build('a') => sentence_factory.build('x_2')
      }
      expect(func_sym.standardize_apart).to eq(expected)
    end
  end

  def sentence_factory
    RuleRover::FirstOrderLogic::Sentences::Factory
  end
end