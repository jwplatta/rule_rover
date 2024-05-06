require 'spec_helper'

describe 'RuleRover::FirstOrderLogic::Sentences::Substitution' do
  describe '#substitute' do
    context 'when the sentence is a conjunction of two variables' do
      it do
        sent = sentence_factory.build('x', :and, 'y')
        mapping = { 'x' => 'Russell', 'y' => 'Moore' }
        expected = sentence_factory.build('Russell', :and, 'Moore')
        new_sent = sent.substitute(mapping)
        expect(new_sent).to eq(expected)
      end
    end
    context 'when the sentence is a disjunction of two variables' do
      it do
        sent = sentence_factory.build('x', :or, 'y')
        mapping = { 'x' => 'Russell', 'y' => 'Moore' }
        expected = sentence_factory.build('Russell', :or, 'Moore')
        new_sent = sent.substitute(mapping)
        expect(new_sent).to eq(expected)
      end
    end
    context 'when the sentence is a conditional of two variables' do
      it do
        sent = sentence_factory.build('x', :then, 'y')
        mapping = { 'x' => 'Russell', 'y' => 'Moore' }
        expected = sentence_factory.build('Russell', :then, 'Moore')
        new_sent = sent.substitute(mapping)
        expect(new_sent).to eq(expected)
      end
    end
    context 'when the sentence is a biconditional of two variables' do
      it do
        sent = sentence_factory.build('x', :iff, 'y')
        mapping = { 'x' => 'Russell', 'y' => 'Moore' }
        expected = sentence_factory.build('Russell', :iff, 'Moore')
        new_sent = sent.substitute(mapping)
        expect(new_sent).to eq(expected)
      end
    end
    context 'when the sentence is a negation of a conjunction of two variables' do
      it do
        sent = sentence_factory.build(:not, ['x', :and, 'y'])
        mapping = { 'x' => 'Russell', 'y' => 'Moore' }
        expected = sentence_factory.build(:not, ['Russell', :and, 'Moore'])
        new_sent = sent.substitute(mapping)
        expect(new_sent).to eq(expected)
      end
    end
    context 'when the sentence is a biconditional of two variables' do
      it do
        sent = sentence_factory.build('x', :iff, 'y')
        mapping = { 'x' => 'Russell', 'y' => 'Moore' }
        expected = sentence_factory.build('Russell', :iff, 'Moore')
        new_sent = sent.substitute(mapping)
        expect(new_sent).to eq(expected)
      end
    end
    context 'when the sentence contains a universal quantifier' do
      it do
        sent = sentence_factory.build(:all, 'x', ['x', :iff, 'Moore'])
        mapping = { 'x' => 'Russell', 'y' => 'Moore' }
        expected = sentence_factory.build(:all, 'Russell', ['Russell', :iff, 'Moore'])
        new_sent = sent.substitute(mapping)
        expect(new_sent).to eq(expected)
      end
    end
    context 'when the sentence contains a existential quantifier' do
      it do
        sent = sentence_factory.build(:some, 'x', ['x', :iff, 'Moore'])
        mapping = { 'x' => 'Russell', 'y' => 'Moore' }
        expected = sentence_factory.build(:some, 'Russell', ['Russell', :iff, 'Moore'])
        new_sent = sent.substitute(mapping)
        expect(new_sent).to eq(expected)
      end
    end
  end

  def sentence_factory
    RuleRover::FirstOrderLogic::Sentences::Factory
  end
end