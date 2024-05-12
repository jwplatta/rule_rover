require 'spec_helper'

describe 'RuleRover::FirstOrderLogic::Sentences::Substitution' do
  describe '#substitute' do
    context 'replacing variables' do
      it do
        orig_var = sentence_factory.build('x')
        mapped_var = sentence_factory.build('y')
        mapping = { orig_var => mapped_var }
        new_sent = orig_var.substitute(mapping)
        expect(new_sent).to eq(mapped_var)
      end
    end
    context 'when the sentence is a conjunction of two variables' do
      it do
        sent = sentence_factory.build('x', :and, 'y')
        mapping = {
          sentence_factory.build('x') => sentence_factory.build('Russell'),
          sentence_factory.build('y') => sentence_factory.build('Moore')
        }
        expected = sentence_factory.build('Russell', :and, 'Moore')
        new_sent = sent.substitute(mapping)
        expect(new_sent).to eq(expected)
      end
    end
    context 'when the sentence is a disjunction of two variables' do
      it do
        sent = sentence_factory.build('x', :or, 'y')
        mapping = {
          sentence_factory.build('x') => sentence_factory.build('Russell'),
          sentence_factory.build('y') => sentence_factory.build('Moore')
        }
        expected = sentence_factory.build('Russell', :or, 'Moore')
        new_sent = sent.substitute(mapping)
        expect(new_sent).to eq(expected)
      end
    end
    context 'when the sentence is a conditional of two variables' do
      it do
        sent = sentence_factory.build('x', :then, 'y')
        mapping = {
          sentence_factory.build('x') => sentence_factory.build('Russell'),
          sentence_factory.build('y') => sentence_factory.build('Moore')
        }
        expected = sentence_factory.build('Russell', :then, 'Moore')
        new_sent = sent.substitute(mapping)
        expect(new_sent).to eq(expected)
      end
    end
    context 'when the sentence is a biconditional of two variables' do
      it do
        sent = sentence_factory.build('x', :iff, 'y')
        mapping = {
          sentence_factory.build('x') => sentence_factory.build('Russell'),
          sentence_factory.build('y') => sentence_factory.build('Moore')
        }
        expected = sentence_factory.build('Russell', :iff, 'Moore')
        new_sent = sent.substitute(mapping)
        expect(new_sent).to eq(expected)
      end
    end
    context 'when the sentence is a negation of a conjunction of two variables' do
      it do
        sent = sentence_factory.build(:not, ['x', :and, 'y'])
        mapping = {
          sentence_factory.build('x') => sentence_factory.build('Russell'),
          sentence_factory.build('y') => sentence_factory.build('Moore')
        }
        expected = sentence_factory.build(:not, ['Russell', :and, 'Moore'])
        new_sent = sent.substitute(mapping)
        expect(new_sent).to eq(expected)
      end
    end
    context 'when the sentence is a biconditional of two variables' do
      it do
        sent = sentence_factory.build('x', :iff, 'y')
        mapping = {
          sentence_factory.build('x') => sentence_factory.build('Russell'),
          sentence_factory.build('y') => sentence_factory.build('Moore')
        }
        expected = sentence_factory.build('Russell', :iff, 'Moore')
        new_sent = sent.substitute(mapping)
        expect(new_sent).to eq(expected)
      end
    end
    context 'when the sentence contains a universal quantifier' do
      it do
        sent = sentence_factory.build(:all, 'x', ['x', :iff, 'Moore'])
        mapping = {
          sentence_factory.build('x') => sentence_factory.build('Russell'),
          sentence_factory.build('y') => sentence_factory.build('Moore')
        }
        expected = sentence_factory.build(:all, 'Russell', ['Russell', :iff, 'Moore'])
        new_sent = sent.substitute(mapping)
        expect(new_sent).to eq(expected)
      end
    end
    context 'when the sentence contains a existential quantifier' do
      it do
        sent = sentence_factory.build(:some, 'x', ['x', :iff, 'Moore'])
        mapping = {
          sentence_factory.build('x') => sentence_factory.build('Russell'),
          sentence_factory.build('y') => sentence_factory.build('Moore')
        }
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