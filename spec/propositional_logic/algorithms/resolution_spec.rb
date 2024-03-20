require 'spec_helper'

describe RuleRover::PropositionalLogic::Algorithms::Resolution do
  it 'does not raise' do
    expect { described_class.new(nil, nil) }.not_to raise_error
  end

  describe '.run' do
    let(:kb) { RuleRover::PropositionalLogic::KnowledgeBase.new(engine=:resolution) }
    it do
      kb.assert("a", :then, "b")
      kb.assert("a")
      expect(described_class.run(kb, "b")).to be true
    end
    it do
      kb.assert("a", :then, "b")
      kb.assert("b")
      expect(described_class.run(kb, "a")).to be false
    end
    it do
      kb.assert("a", :or, "b")
      kb.assert(:not, "b")
      expect(described_class.run(kb, "a")).to be true
    end
    it do
      kb.assert(["matt", :and, "ben"], :then, "joe")
      kb.assert(:not, "joe")
      query1 = ["matt", :and, "ben"]
      expect(described_class.run(kb, *query1)).to be false

      query2 = [:not, ["matt", :and, "ben"]]
      expect(described_class.run(kb, *query2)).to be true

      query3 = [:not, "matt", :or, :not, "ben"]
      expect(described_class.run(kb, *query3)).to be true
    end
    it do
      kb.assert(:not, ["a", :and, "b"])
      kb.assert("x", :then, "y")
      kb.assert(:not, "y")
      query = [:not, "x"]
      expect(described_class.run(kb, *query)).to be true
    end
    describe 'when sentence is not proveable' do
      around(:each) do |test|
        start_time = Time.now
        puts "Starting: #{test.description}"
        puts "WARNING: The test '#{test.description}' takes ~30 seconds."

        test.run

        end_time = Time.now
        duration = end_time - start_time
        puts "Finished: #{test.description}. Duration: #{duration} seconds."
      end
      it 'explore all possible clauses' do
        kb.assert ["a", :and, "c"], :iff, "b"
        kb.assert "b"
        query1 = ["a", :and, "c"]
        expect(described_class.run(kb, *query1)).to be true
        expect(described_class.run(kb, "d")).to be false
      end
    end
  end

  def sentence_factory
    RuleRover::PropositionalLogic::Sentences::Factory
  end
end
