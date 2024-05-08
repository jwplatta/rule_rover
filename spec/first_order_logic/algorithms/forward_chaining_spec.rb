require 'spec_helper'

describe RuleRover::FirstOrderLogic::Algorithms::ForwardChaining do
  xit do
    kb = RuleRover::FirstOrderLogic::KnowledgeBase.new
    kb.assert()
    binding.pry
    # subject.forward_chain
  end
  describe '.definite_clause?' do
    context 'is a clause with a single positive literal' do
      fit do
        sentence = sentence_factory.build([:not, ['Plato', :taught, 'Socrates'], :or, :not, ['Alexander', :taught, 'Aristotle']], :or, ['Aristotle', :taught, 'Alexander'])
        expect(subject.definite_clause?(sentence)).to be(true)
      end
    end
    context 'is a clause with a multiple positive literals' do
      it do
        sentence = sentence_factory.build(:not, ['Plato', :taught, 'Socrates'], :or, :not, ['Alexander', :taught, 'Aristotle'])
      end
    end
  end

  def sentence_factory
    RuleRover::FirstOrderLogic::Sentences::Factory
  end
end