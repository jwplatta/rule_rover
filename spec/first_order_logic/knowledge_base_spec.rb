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
  describe '#assert' do
    it 'adds sentence with standardized variables' do
      expected = sentence_factory.build("x_1", :and, "x_2")
      subject.assert("a", :and, "b")
      expect(subject.sentences).to include(expected)
      expect(subject.constants.size).to eq 0
    end
    it 'adds a predicate' do
      sent = ['Aristotle', :taught, 'Alexander']
      expected = sentence_factory.build(*sent)
      subject.assert(*sent)
      expect(subject.sentences).to include(expected)
      expect(subject.constants.size).to eq 2
    end
    it 'adds a function' do
      expected = sentence_factory.build(:@father_of, 'x_1')
      subject.assert(:@father_of, 'x')
      expect(subject.sentences).to include(expected)
      expect(subject.constants.size).to eq 0
    end
    it 'adds a negation' do
      expected = sentence_factory.build(:not, ['x_1', :and, 'x_2'])
      subject.assert(:not, ['x', :and, 'y'])
      expect(subject.sentences).to include(expected)
      expect(subject.constants.size).to eq 0
    end
    it 'adds a conjunction' do
      expected = sentence_factory.build('x_1', :and, 'x_2')
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
      expected = sentence_factory.build('x_1', :then, 'x_2')
      subject.assert('a', :then, 'b')
      expect(subject.sentences).to include(expected)
      expect(subject.constants.size).to eq 0
    end
    it 'adds a biconditional' do
      expected = sentence_factory.build('x_1', :iff, 'x_2')
      subject.assert('a', :iff, 'b')
      expect(subject.sentences).to include(expected)
      expect(subject.constants.size).to eq 0
    end
    it 'adds a universal quantifier' do
      expected = sentence_factory.build(:all, 'x_1', [[:@brother, 'x_2', 'x_1'], :then, [:@sibling, 'x_2', 'x_1']])
      subject.assert(:all, 'y', [[:@brother, 'x', 'y'], :then, [:@sibling, 'x', 'y']])
      expect(subject.sentences).to include(expected)
      expect(subject.constants.size).to eq 0
    end
    it 'adds an existential quantifier' do
      expected = sentence_factory.build(:some, 'x_1', [['x_2', :taught,  'x_1'], :then, ['x_1', :taught, 'x_2']])
      subject.assert(:some, 'y', [['x', :taught,  'y'], :then, ['y', :taught, 'x']])
      expect(subject.sentences).to include(expected)
      expect(subject.constants.size).to eq 0
    end
    it 'adds an equality' do
      expected = sentence_factory.build([[:@father_of, 'x_1'], :and, [:@father_of, 'x_2']], :and, ['x_1',:equals, 'x_2'])
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
          expect(subject.match?('Maureen', :and, 'Monkey')).to be false
        end
      end
    end
  end
  describe '#create_constant' do
    it do
      subject.assert('C1')
      subject.assert('C3')
      new_constant = subject.create_constant

      expect(new_constant).to eq sentence_factory.build('C2')
      expect(subject.constants.size).to eq 3
    end
  end

  xdescribe '#entail' do
  end

  def sentence_factory
    RuleRover::FirstOrderLogic::Sentences::Factory
  end
end
