require 'spec_helper'

describe RuleRover::FirstOrderLogic::Algorithms::BackwardChaining do
  describe '#rules_for_goal' do
    context 'when no rules for goals' do
      it do
        kb = RuleRover::FirstOrderLogic::KnowledgeBase.new
        kb.assert(['Plato', :taught, 'Aristotle'], :then, ['Aristotle', :taught, 'Alexander'])
        kb.assert(['Plato', :taught, 'Aristotle'], :then, ['Aristotle', :taught, 'Socrates'])
        goal = sentence_factory.build('Alexander', :taught, 'Aristotle')

        expect(described_class.new(kb, goal).rules_for_goal(goal)).to eq([])
      end
    end
    context 'when one rule for the goal' do
      it do
        kb = RuleRover::FirstOrderLogic::KnowledgeBase.new
        rule_for_goal = sentence_factory.build(['Plato', :taught, 'Aristotle'], :then, ['Aristotle', :taught, 'Alexander'])
        kb.assert(['Plato', :taught, 'Aristotle'], :then, ['Aristotle', :taught, 'Alexander'])
        kb.assert(['Plato', :taught, 'Aristotle'], :then, ['Aristotle', :taught, 'Socrates'])
        goal = sentence_factory.build('Aristotle', :taught, 'Alexander')

        expect(described_class.new(kb, goal).rules_for_goal(goal)).to eq([rule_for_goal])
      end
    end
    context 'when multiple rules for the goal' do
      it do
        kb = RuleRover::FirstOrderLogic::KnowledgeBase.new
        kb.assert(['Socrates', :taught, 'Plato'], :then, ['Aristotle', :taught, 'Alexander'])
        kb.assert(['Plato', :taught, 'Aristotle'], :then, ['Aristotle', :taught, 'Alexander'])
        kb.assert(['Plato', :taught, 'Aristotle'], :then, ['Aristotle', :taught, 'Socrates'])

        goal = sentence_factory.build('Aristotle', :taught, 'Alexander')
        rules_for_goal = [
          sentence_factory.build(['Socrates', :taught, 'Plato'], :then, ['Aristotle', :taught, 'Alexander']),
          sentence_factory.build(['Plato', :taught, 'Aristotle'], :then, ['Aristotle', :taught, 'Alexander'])
        ]

        expect(described_class.new(kb, goal).rules_for_goal(goal)).to eq(rules_for_goal)
      end
    end
  end
  describe '.backward_chain' do
    context 'knowledge base contains the query' do
      it 'returns an empty substitution' do
        kb = RuleRover::FirstOrderLogic::KnowledgeBase.new
        kb.assert([:not, ['Alexander', :taught, 'Aristotle']], :or, ['Socrates', :taught, 'Plato'])
        kb.assert('Alexander', :taught, 'Aristotle')
        query = sentence_factory.build('Alexander', :taught, 'Aristotle')
        result = described_class.backward_chain(kb, query)

        expect(result).to eq({})
      end
    end
    context 'knowledge base does not contain the query' do
      it 'returns an empty substitution' do
        kb = RuleRover::FirstOrderLogic::KnowledgeBase.new
        kb.assert(['Alexander', :taught, 'Aristotle'], :then, ['Socrates', :taught, 'Plato'])
        kb.assert('Alexander', :taught, 'Aristotle')
        query = sentence_factory.build('Socrates', :taught, 'Plato')
        result = described_class.backward_chain(kb, query)

        expect(result).to eq({})
      end
      it 'returns an empty substitution' do
        kb = RuleRover::FirstOrderLogic::KnowledgeBase.new
        kb.assert([['Socrates', :taught, 'Plato'], :and, ['Plato', :taught, 'Aristotle']], :then, ['Alexander', :knows_about, 'Socrates'])
        kb.assert('Socrates', :taught, 'Plato')
        kb.assert('Plato', :taught, 'Aristotle')
        query = sentence_factory.build('Alexander', :knows_about, 'Socrates')
        substitution = described_class.backward_chain(kb, query)
        expect(substitution).to eq({})
      end
      it 'returns an empty substitution' do
        kb = RuleRover::FirstOrderLogic::KnowledgeBase.new
        kb.assert(['Socrates', :knows, 'Plato'], :then, ['Plato', :knows, 'Aristotle'])
        kb.assert(['Plato', :knows, 'Aristotle'], :then, ['Aristotle', :knows, 'Alexander'])
        kb.assert('Socrates', :knows, 'Plato')
        query = sentence_factory.build('Aristotle', :knows, 'Alexander')
        substitution = described_class.backward_chain(kb, query)

        expect(substitution).to eq({})
      end
      it 'returns an empty substitution' do
        kb = RuleRover::FirstOrderLogic::KnowledgeBase.new
        kb.assert([['Russell', :studied, 'Plato'], :and, ['Socrates', :knows, 'Plato']], :then, ['Plato', :knows, 'Aristotle'])
        kb.assert(['Plato', :knows, 'Aristotle'], :then, ['Aristotle', :knows, 'Alexander'])
        kb.assert(['Moore', :studied, 'Plato'], :then, ['Russell', :studied, 'Plato'])
        kb.assert('Moore', :studied, 'Plato')
        kb.assert('Socrates', :knows, 'Plato')
        query = sentence_factory.build('Aristotle', :knows, 'Alexander')
        substitution = described_class.backward_chain(kb, query)

        expect(substitution).to eq({})
      end
    end
    context 'knowledge base contains a sentence with a variable' do
      fit do
        kb = RuleRover::FirstOrderLogic::KnowledgeBase.new
        kb.assert([['Russell', :studied, 'x'], :and, ['Socrates', :knows, 'x']], :then, ['x', :knows, 'Aristotle'])
        kb.assert(['Plato', :knows, 'x'], :then, ['x', :knows, 'Alexander'])
        kb.assert(['Moore', :studied, 'x'], :then, ['Russell', :studied, 'x'])
        kb.assert('Moore', :studied, 'Plato')
        kb.assert('Socrates', :knows, 'Plato')
        query = sentence_factory.build('Aristotle', :knows, 'Alexander')
        substitution = described_class.backward_chain(kb, query)
        binding.pry

        expect(substitution).to be({})
      end
    end
  end
  def sentence_factory
    RuleRover::FirstOrderLogic::Sentences::Factory
  end
end
