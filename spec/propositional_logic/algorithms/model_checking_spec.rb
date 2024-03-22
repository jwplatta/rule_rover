require 'spec_helper'

describe RuleRover::PropositionalLogic::Algorithms::ModelChecking do
  it 'does not raise' do
    expect { described_class.new(nil, nil) }.not_to raise_error
  end

  describe '.run' do
    let(:kb) { RuleRover::PropositionalLogic::KnowledgeBase.new(engine: :model_checking) }

    it do
      kb.assert("a", :then, "b")
      kb.assert("a")
      expect(described_class.run(kb: kb, query: "b")).to be true
    end
    it do
      kb.assert("a", :then, "b")
      kb.assert("b")
      expect(described_class.run(kb: kb, query: "a")).to be false
    end
    it do
      kb.assert("a", :or, "b")
      kb.assert(:not, "b")
      expect(described_class.run(kb: kb, query: "a")).to be true
    end
    it do
      kb.assert(["matt", :and, "ben"], :then, "joe")
      kb.assert(:not, "joe")

      query1 = ["matt", :and, "ben"]
      expect(described_class.run(kb: kb, query: query1)).to be false

      query2 = [:not, ["matt", :and, "ben"]]
      expect(described_class.run(kb: kb, query: query2)).to be true

      query3 = [:not, "matt", :or, :not, "ben"]
      expect(described_class.run(kb: kb, query: query3)).to be true
    end
  end

  def sentence_factory
    RuleRover::PropositionalLogic::Sentences::Factory
  end
end