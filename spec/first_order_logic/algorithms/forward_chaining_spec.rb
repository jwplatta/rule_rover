require 'spec_helper'

describe RuleRover::FirstOrderLogic::Algorithms::ForwardChaining do
  describe '.forward_chain' do
    context 'knowledge base contains the query' do
      it do
        kb = RuleRover::FirstOrderLogic::KnowledgeBase.new
        kb.assert([:not, ['Alexander', :taught, 'Aristotle']], :or, ['Socrates', :taught, 'Plato'])
        kb.assert('Alexander', :taught, 'Aristotle')
        query = sentence_factory.build('Alexander', :taught, 'Aristotle')

        expect(described_class.forward_chain(kb, query)).to be(true)
      end
    end
    context 'knowledge base does not contain the query' do
      it do
        kb = RuleRover::FirstOrderLogic::KnowledgeBase.new
        kb.assert(['Alexander', :taught, 'Aristotle'], :then, ['Socrates', :taught, 'Plato'])
        kb.assert('Alexander', :taught, 'Aristotle')
        query = sentence_factory.build('Socrates', :taught, 'Plato')

        expect(described_class.forward_chain(kb, query)).to be(true)
      end
      it do
        kb = RuleRover::FirstOrderLogic::KnowledgeBase.new
        kb.assert([['Socrates', :taught, 'Plato'], :and, ['Plato', :taught, 'Aristotle']], :then, ['Alexander', :knows_about, 'Socrates'])
        kb.assert('Socrates', :taught, 'Plato')
        kb.assert('Plato', :taught, 'Aristotle')
        query = sentence_factory.build('Alexander', :knows_about, 'Socrates')

        expect(described_class.forward_chain(kb, query)).to be(true)
      end
      it do
        kb = RuleRover::FirstOrderLogic::KnowledgeBase.new
        kb.assert(['Socrates', :knows, 'Plato'], :then, ['Plato', :knows, 'Aristotle'])
        kb.assert(['Plato', :knows, 'Aristotle'], :then, ['Aristotle', :knows, 'Alexander'])
        kb.assert('Socrates', :knows, 'Plato')
        query = sentence_factory.build('Aristotle', :knows, 'Alexander')

        expect(described_class.forward_chain(kb, query)).to be(true)
      end
      it do
        kb = RuleRover::FirstOrderLogic::KnowledgeBase.new
        kb.assert([['Russell', :studied, 'Plato'], :and, ['Socrates', :knows, 'Plato']], :then, ['Plato', :knows, 'Aristotle'])
        kb.assert(['Plato', :knows, 'Aristotle'], :then, ['Aristotle', :knows, 'Alexander'])
        kb.assert(['Moore', :studied, 'Plato'], :then, ['Russell', :studied, 'Plato'])
        kb.assert('Moore', :studied, 'Plato')
        kb.assert('Socrates', :knows, 'Plato')
        query = sentence_factory.build('Aristotle', :knows, 'Alexander')

        expect(described_class.forward_chain(kb, query)).to be(true)
      end
    end
    context 'knowledge base contains a sentence with a variable' do
      it do
        kb = RuleRover::FirstOrderLogic::KnowledgeBase.new
        kb.assert([['Russell', :studied, 'x'], :and, ['Socrates', :knows, 'x']], :then, ['x', :knows, 'Aristotle'])
        kb.assert(['Plato', :knows, 'x'], :then, ['x', :knows, 'Alexander'])
        kb.assert(['Moore', :studied, 'x'], :then, ['Russell', :studied, 'x'])
        kb.assert('Moore', :studied, 'Plato')
        kb.assert('Socrates', :knows, 'Plato')
        query = sentence_factory.build('Aristotle', :knows, 'Alexander')

        expect(described_class.forward_chain(kb, query)).to be(true)
      end
    end
  end

  describe '#antecedent_and_consequent' do
    context 'is a clause with a single positive literal' do
      it 'returns the antecedent and consequent' do
        clause = sentence_factory.build('Plato', :taught, 'Socrates')
        antecedent, consequent = described_class.new(
          nil,
          sentence_factory.build('x')
        ).antecedent_and_consequent(clause)
        expect(antecedent).to eq(clause)
        expect(consequent).to eq(clause)
      end
    end
    context 'is a clause with a multiple positive literals' do
      it 'returns the antecedent and consequent' do
        clause = sentence_factory.build([['Plato', :taught, 'Socrates'], :and, ['Alexander', :taught, 'Aristotle']], :then, ['Socrates', :taught, 'Plato'])
        antecedent, consequent = described_class.new(nil, sentence_factory.build('x')).antecedent_and_consequent(clause)
        expect(antecedent).to eq(sentence_factory.build(['Plato', :taught, 'Socrates'], :and, ['Alexander', :taught, 'Aristotle']))
        expect(consequent).to eq(sentence_factory.build('Socrates', :taught, 'Plato'))
      end
    end
    context 'not a conditional' do
      it 'returns nil' do
        clause = sentence_factory.build([:not, ['Plato', :taught, 'Socrates']], :and , ['Socrates', :taught, 'Plato'])
        antecedent, consequent = described_class.new(nil, sentence_factory.build('x')).antecedent_and_consequent(clause)
        expect(antecedent).to be_nil
        expect(consequent).to be_nil
      end
    end
  end
  def sentence_factory
    RuleRover::FirstOrderLogic::Sentences::Factory
  end
end