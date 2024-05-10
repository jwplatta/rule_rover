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
      it do
        kb = RuleRover::FirstOrderLogic::KnowledgeBase.new
        kb.assert([:not, ['Alexander', :taught, 'Aristotle']], :or, ['Socrates', :taught, 'Plato'])
        kb.assert('Alexander', :taught, 'Aristotle')
        query = sentence_factory.build('Socrates', :taught, 'Plato')

        expect(described_class.forward_chain(kb, query)).to be(true)
      end
    end
  end

  describe '#antecedents_and_consequent' do
    it 'returns an array of antecedents and a consequent' do
      clause = sentence_factory.build([[:not, ['Plato', :or, 'Socrates']], :or, [:not, ['Alexander', :taught, 'Aristotle']]], :or, ['Socrates', :taught, 'Plato'])
      antecedents, consequent = described_class.new(nil, nil).antecedents_and_consequent(clause)

      expect(antecedents).to eq([
        sentence_factory.build(:not, ['Plato', :or, 'Socrates']),
        sentence_factory.build(:not, ['Alexander', :taught, 'Aristotle'])
      ])
      expect(consequent).to eq(sentence_factory.build('Socrates', :taught, 'Plato'))
    end
  end
  describe '#definite_clause?' do
    context 'is a clause with a single positive literal' do
      it do
        sentence = sentence_factory.build([:not, ['Plato', :taught, 'Socrates'], :or, :not, ['Alexander', :taught, 'Aristotle']], :or, ['Aristotle', :taught, 'Alexander'])
        expect(described_class.new(nil, nil).definite_clause?(sentence)).to be(true)
      end
    end
    context 'is a clause with a multiple positive literals' do
      it do
        sentence = sentence_factory.build(:not, ['Plato', :taught, 'Socrates'], :or, :not, ['Alexander', :taught, 'Aristotle'])
        expect(described_class.new(nil, nil).definite_clause?(sentence)).to be(false)
      end
    end
  end

  def sentence_factory
    RuleRover::FirstOrderLogic::Sentences::Factory
  end
end