require 'spec_helper'

describe RuleRover::PropositionalLogic::Algorithms::ForwardChaining do
  it 'does not raise' do
    expect { described_class.new(nil, nil) }.not_to raise_error
  end

  describe '.run' do
    it do
      kb = RuleRover::PropositionalLogic::KnowledgeBase.new(engine: :forward_chaining)
      kb.assert("a", :then, "b")
      kb.assert("a")
      kb = kb.to_cnf
      query = sentence_factory.build("b")

      expect(described_class.run(kb: kb, query: query)).to be true
    end

    it do
      kb = RuleRover::PropositionalLogic::KnowledgeBase.new(engine: :forward_chaining)
      kb.assert("a", :iff, "b")
      kb.assert("b", :then, "c")
      kb.assert("c", :then, "d")
      kb.assert("d", :then, [:not, "e", :or, "f"])
      kb.assert("a")
      kb.assert("e")
      kb = kb.to_cnf
      query = sentence_factory.build("f")

      expect(described_class.run(kb: kb, query: query)).to be true
    end
  end

  def sentence_factory
    RuleRover::PropositionalLogic::Sentences::Factory
  end
end