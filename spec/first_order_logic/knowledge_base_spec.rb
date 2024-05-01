require 'spec_helper'

describe RuleRover::FirstOrderLogic::KnowledgeBase do
  it 'does not raise' do
    expect { described_class.new }.not_to raise_error
  end
  describe 'constants' do
    describe '#connectives' do
      it do
        expect(subject.connectives).to eq RuleRover::FirstOrderLogic::CONNECTIVES
      end
    end
    describe '#operators' do
      it do
        expect(subject.operators).to eq RuleRover::FirstOrderLogic::OPERATORS
      end
    end
    describe '#quantifiers' do
      it do
        expect(subject.quantifiers).to eq RuleRover::FirstOrderLogic::QUANTIFIERS
      end
    end
  end
  fdescribe '#assert' do
    it 'adds a constant' do
      expected = sentence_factory.build("a", :and, "b")
      subject.assert("a", :and, "b")
      expect(subject.sentences).to include(expected)
      expect(subject.constants.size).to eq 0
    end
    it 'adds a predicate' do
      expected = sentence_factory.build('Aristotle', :taught, 'Alexander')
      subject.assert('Aristotle', :taught, 'Alexander')
      expect(subject.sentences).to include(expected)
      expect(subject.constants.size).to eq 2
    end
    it 'adds a function' do
      expected = sentence_factory.build(:@father_of, 'x')
      subject.assert(:@father_of, 'x')
      expect(subject.sentences).to include(expected)
      expect(subject.constants.size).to eq 0
    end
    it 'adds a negation' do
      expected = sentence_factory.build(:not, ['x', :and, 'y'])
      subject.assert(:not, ['x', :and, 'y'])
      expect(subject.sentences).to include(expected)
      expect(subject.constants.size).to eq 0
    end
    it 'adds a conjunction' do
      expected = sentence_factory.build('a', :and, 'b')
      subject.assert('a', :and, 'b')
      expect(subject.sentences).to include(expected)
      expect(subject.constants.size).to eq 0
    end
    it 'adds a disjunction' do
      expected = sentence_factory.build(['Plato', :taught, 'Aristotle'], :or, ['Aristotle', :taught, 'Alexander'])
      subject.assert(['Plato', :taught, 'Aristotle'], :or, ['Aristotle', :taught, 'Alexander'])
      expect(subject.sentences).to include(expected)
      expect(subject.constants.size).to eq 3
    end
    it 'adds an implication' do
      expected = sentence_factory.build('a', :then, 'b')
      subject.assert('a', :then, 'b')
      expect(subject.sentences).to include(expected)
      expect(subject.constants.size).to eq 0
    end
    it 'adds a biconditional' do
      expected = sentence_factory.build('a', :iff, 'b')
      subject.assert('a', :iff, 'b')
      expect(subject.sentences).to include(expected)
      expect(subject.constants.size).to eq 0
    end
    it 'adds a universal quantifier' do
      expected = sentence_factory.build(:all, 'y', [[:@brother, 'x', 'y'], :then, [:@sibling, 'x', 'y']])
      subject.assert(:all, 'y', [[:@brother, 'x', 'y'], :then, [:@sibling, 'x', 'y']])
      expect(subject.sentences).to include(expected)
      expect(subject.constants.size).to eq 0
    end
    it 'adds an existential quantifier' do
      expected = sentence_factory.build(:some, 'y', [['x', :taught,  'y'], :then, ['y', :taught, 'x']])
      subject.assert(:some, 'y', [['x', :taught,  'y'], :then, ['y', :taught, 'x']])
      expect(subject.sentences).to include(expected)
      expect(subject.constants.size).to eq 0
    end
    it 'adds an equality' do
      expected = sentence_factory.build([[:@father_of, 'x'], :and, [:@father_of, 'y']], :and, ['x',:equals, 'y'])
      subject.assert([[:@father_of, 'x'], :and, [:@father_of, 'y']], :and, ['x', :equals, 'y'])
      expect(subject.sentences).to include(expected)
      expect(subject.constants.size).to eq 0
    end
  end
  describe '#match' do
    describe 'when knowledge base is empty' do
      it 'returns false' do
        expect(subject.match?('Joe', :and, 'Matthew')).to be false
      end
    end
    describe 'when knowledge base is not empty' do
      before do
        subject.assert('Joe', :and, 'Matthew')
        subject.assert('Ben', :and, 'Joe')
        subject.assert('x', :and, 'Joe')
      end
      context 'when knowledge base contains a match' do
        it 'returns sentence from knowledge base' do
          match = subject.match?('Maureen', :and, 'Joe')
          expect(match).to be subject.sentences.last
        end
      end
      context 'when knowledge base contains no match' do
        it 'returns nil' do
          expect(subject.match?('Maureen', :and, 'Monkey')).to be nil
        end
      end
    end
  end
  xdescribe '#entail' do
  end

  def sentence_factory
    RuleRover::FirstOrderLogic::Sentences::Factory
  end
end