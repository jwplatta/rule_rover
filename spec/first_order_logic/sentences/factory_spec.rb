require 'spec_helper'

describe RuleRover::FirstOrderLogic::Sentences::Factory do
  it 'does not raise' do
    expect { described_class.new }.not_to raise_error
  end

  describe '.build' do
    describe 'when given a constant symbol' do
      it 'returns a ConstantSymbol object' do
        expect(described_class.build('Aristotle')).to be_a RuleRover::FirstOrderLogic::Sentences::ConstantSymbol
      end
    end
    describe 'when given a function symbol' do
      it 'returns a FunctionSymbol' do
        expect(described_class.build(:@teacher_of, 'Aristotle')).to be_a RuleRover::FirstOrderLogic::Sentences::FunctionSymbol
      end
    end
    describe 'when given a predicate symbol' do
      it 'returns a PredicateSymbol' do
        expect(described_class.build('Plato', :taught, 'Aristotle')).to be_a RuleRover::FirstOrderLogic::Sentences::PredicateSymbol
      end
    end

    describe 'when given a negation' do
      it do
        expect(
          described_class.build(:not, [['Plato', :taught, 'Aristotle'], :and, ['Aristotle', :taught, 'Alexander']])
        ).to be_a RuleRover::FirstOrderLogic::Sentences::Negation
      end
      it do
        expect(
          described_class.build(['Plato', :taught, 'Aristotle'], :and, :not, ['Aristotle', :taught, 'Alexander']).to_s
        ).to eq "[[Plato :taught Aristotle] :and [:not [Aristotle :taught Alexander]]]"
      end
      it do
        expect(
        described_class.build(:not, ['Plato', :taught, 'Aristotle'], :and, ['Aristotle', :taught, 'Alexander']).to_s
        ).to eq "[[:not [Plato :taught Aristotle]] :and [Aristotle :taught Alexander]]"
      end
    end

    describe 'when given a connector' do
      it 'returns a conjunction' do
        expect(
          described_class.build(['Plato', :taught, 'Aristotle'], :and, ['Aristotle', :taught, 'Alexander'])
        ).to be_a RuleRover::FirstOrderLogic::Sentences::Conjunction
      end

      it 'returns a disjunction' do
        expect(
          described_class.build(['Plato', :taught, 'Aristotle'], :or, ['Aristotle', :taught, 'Alexander'])
        ).to be_a RuleRover::FirstOrderLogic::Sentences::Disjunction
      end

      it 'returns a conditional' do
        expect(
          described_class.build(['Plato', :taught, 'Aristotle'], :then, ['Aristotle', :taught, 'Alexander'])
        ).to be_a RuleRover::FirstOrderLogic::Sentences::Conditional
      end

      it 'returns a biconditional' do
        expect(
          described_class.build(['Plato', :taught, 'Aristotle'], :iff, ['Aristotle', :taught, 'Alexander'])
        ).to be_a RuleRover::FirstOrderLogic::Sentences::Biconditional
      end

      it do
        expect(
          described_class.build([['Plato', :taught, 'Aristotle'], :iff, :not, ['Aristotle', :taught, 'Alexander']], :and, [[:@teacher_of, 'Socrates'], :or, 'Alcibides']).to_s
        ).to eq "[[[Plato :taught Aristotle] :iff [:not [Aristotle :taught Alexander]]] :and [[:@teacher_of Socrates] :or Alcibides]]"
      end
    end
  end
end