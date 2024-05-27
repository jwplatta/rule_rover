require "spec_helper"

describe RuleRover::PropositionalLogic::Algorithms::Resolution do
  it "does not raise" do
    expect { described_class.new(nil, nil) }.not_to raise_error
  end

  describe ".run" do
    let(:kb) { RuleRover::PropositionalLogic::KnowledgeBase.new(engine: :resolution) }
    it do
      kb.assert("a", :then, "b")
      kb.assert("a")
      query = sentence_factory.build("b")
      expect(described_class.run(kb: kb, query: query)).to be true
    end
    it do
      kb.assert("a", :then, "b")
      kb.assert("b")
      query = sentence_factory.build("a")
      expect(described_class.run(kb: kb, query: query)).to be false
    end
    it do
      kb.assert("a", :or, "b")
      kb.assert(:not, "b")
      query = sentence_factory.build("a")
      expect(described_class.run(kb: kb, query: query)).to be true
    end
    it do
      kb.assert(["matt", :and, "ben"], :then, "joe")
      kb.assert(:not, "joe")
      query1 = sentence_factory.build("matt", :and, "ben")
      expect(described_class.run(kb: kb, query: query1)).to be false

      query2 = sentence_factory.build(:not, ["matt", :and, "ben"])
      expect(described_class.run(kb: kb, query: query2)).to be true

      query3 = sentence_factory.build(:not, "matt", :or, :not, "ben")
      expect(described_class.run(kb: kb, query: query3)).to be true
    end
    it do
      kb.assert(:not, ["a", :and, "b"])
      kb.assert("x", :then, "y")
      kb.assert(:not, "y")
      query = sentence_factory.build(:not, "x")
      expect(described_class.run(kb: kb, query: query)).to be true
    end
    describe "when sentence is not proveable" do
      around(:each) do |test|
        start_time = Time.now
        puts "Starting: #{test.description}"
        puts "WARNING: The test '#{test.description}' takes ~30 seconds."

        test.run

        end_time = Time.now
        duration = end_time - start_time
        puts "Finished: #{test.description}. Duration: #{duration} seconds."
      end
      it "explore all possible clauses" do
        kb.assert ["a", :and, "c"], :iff, "b"
        kb.assert "b"
        query1 = sentence_factory.build("a", :and, "c")
        expect(described_class.run(kb: kb, query: query1)).to be true
        query2 = sentence_factory.build("d")
        expect(described_class.run(kb: kb, query: query2)).to be false
      end
    end
  end

  def sentence_factory
    RuleRover::PropositionalLogic::Sentences::Factory
  end
end
