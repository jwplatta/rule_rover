require 'spec_helper'

describe RuleRover::FirstOrderLogic::Sentences::FunctionSymbol do
  it 'does not raise' do
    expect { described_class.new(name: nil, args: []) }.not_to raise_error
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
    end
  end
  describe '#==' do
    context 'sentences have the same meaning'  do
      it 'returns true' do
        funct_sym_one = sentence_factory.build(:@cave_of, 'Plato')
        funct_sym_two = sentence_factory.build(:@cave_of, 'Plato')
        expect(funct_sym_one == funct_sym_two).to be(true)
      end
      it 'returns true' do
        funct_sym_one = sentence_factory.build(:@student_of, 'x')
        funct_sym_two = sentence_factory.build(:@student_of, 'y')
        expect(funct_sym_one == funct_sym_two).to be(true)
      end
    end
    context 'sentences have different meanings'  do
      it 'returns false' do
        func_sym_one = sentence_factory.build(:@son_of, 'x')
        func_sym_two = sentence_factory.build(:@father_of, 'x')
        expect(func_sym_one == func_sym_two).to be(false)
      end
    end
  end

  def sentence_factory
    RuleRover::FirstOrderLogic::Sentences::Factory
  end
end