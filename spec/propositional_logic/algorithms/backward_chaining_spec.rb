require "spec_helper"

describe RuleRover::PropositionalLogic::Algorithms::BackwardChaining do
  it "does not raise" do
    expect { described_class.new(nil, nil) }.not_to raise_error
  end

  describe "#find_pure_symbol" do
    it do
      kb = RuleRover::PropositionalLogic::KnowledgeBase.new(engine: :backward_chaining)
      kb.assert("a", :or, "b")
      kb.assert(:not, "b", :or, "c")
      clauses = kb.to_clauses.sentences
      model = { "c" => false, "b" => false }

      expect(
        described_class.new(nil, nil).find_pure_symbol({}, clauses, model)
      ).to eq(["a", true])
    end

    it do
      kb = RuleRover::PropositionalLogic::KnowledgeBase.new(engine: :backward_chaining)
      kb.assert("a", :or, "b")
      kb.assert("a", :or, :not, "b") # ignores
      kb.assert("a", :or, "c")
      kb.assert(:not, "a", :or, "d")
      clauses = kb.to_clauses.sentences
      model = { "b" => false }

      expect(
        described_class.new(nil, nil).find_pure_symbol({}, clauses, model)
      ).to eq(["c", true])
    end

    it "excludes true clauses" do
      kb = RuleRover::PropositionalLogic::KnowledgeBase.new(engine: :backward_chaining)
      kb.assert("a", :or, "b")
      kb.assert("a", :or, :not, "b")
      kb.assert("a", :or, "c")
      kb.assert(:not, "a", :or, "d")
      kb.assert("e", :or, "f")

      clauses = kb.to_clauses.sentences
      model = { "a" => false, "b" => false, "c" => true }

      expect(
        described_class.new(nil, nil).find_pure_symbol(model.keys, clauses, model)
      ).to eq ["e", true]
    end

    describe "when there is no pure symbol" do
      it do
        kb = RuleRover::PropositionalLogic::KnowledgeBase.new(engine: :backward_chaining)
        kb.assert("a", :or, "b")
        kb.assert("a", :or, :not, "b")
        kb.assert("a", :or, "c")
        kb.assert(:not, "a", :or, :not, "c")

        clauses = kb.to_clauses.sentences

        expect(
          described_class.new(nil, nil).find_pure_symbol({}, clauses, {})
        ).to eq([nil, false])
      end

      it do
        kb = RuleRover::PropositionalLogic::KnowledgeBase.new(engine: :backward_chaining)
        kb.assert("a", :or, "b")
        kb.assert("a", :or, :not, "b")
        kb.assert("a", :or, "c")

        clauses = kb.to_clauses.sentences
        model = { "a" => true, "b" => false, "c" => false }

        expect(
          described_class.new(nil, nil).find_pure_symbol(model.keys, clauses, model)
        ).to eq([nil, false])
      end

      it do
        kb = RuleRover::PropositionalLogic::KnowledgeBase.new(engine: :backward_chaining)
        kb.assert("a", :then, "b")
        kb.assert("a")
        clauses = kb.to_clauses.sentences
        model = { "b" => true }

        expect(
          described_class.new(nil, nil).find_pure_symbol(model.keys, clauses, model)
        ).to eq([nil, false])
      end
    end
  end

  describe "#is_unit?" do
    it do
      clause = sentence_factory.build("a", :or, "b")
      model = { "a" => false }

      expect(described_class.new(nil, nil).is_unit?(clause, model)).to eq sentence_factory.build("b")
    end

    it do
      clause = sentence_factory.build(:not, "a", :or, "b")
      model = { "b" => false }

      expect(described_class.new(nil, nil).is_unit?(clause, model)).to eq sentence_factory.build(:not, "a")
    end

    it do
      clause = sentence_factory.build(:not, "a", :or, "b")
      model = { "b" => false, "a" => true }

      expect(described_class.new(nil, nil).is_unit?(clause, model)).to eq nil
    end

    it do
      clause = sentence_factory.build(:not, "a", :or, ["b", :or, "c"])
      model = { "b" => false }

      expect(described_class.new(nil, nil).is_unit?(clause, model)).to eq nil
    end

    describe "when all literals except one are false" do
      it do
        clause = sentence_factory.build("a", :or, ["b", :or, "c"])
        model = { "a" => false, "b" => false }

        expect(described_class.new(nil, nil).is_unit?(clause, model)).to eq sentence_factory.build("c")
      end
    end

    describe "when one literal is already true" do
      it do
        clause = sentence_factory.build("a", :or, ["b", :or, "c"])
        model = { "a" => true, "b" => false }

        expect(described_class.new(nil, nil).is_unit?(clause, model)).to eq nil
      end
    end
  end

  describe "#find_unit_clause" do
    it do
      clauses = [
        sentence_factory.build("a", :or, "b"),
        sentence_factory.build("a")
      ]
      model = { "a" => false }

      expect(described_class.new(nil, nil).find_unit_clause(clauses, model)).to eq ["b", true]
    end

    it do
      clauses = [
        sentence_factory.build(:not, "a", :or, "b"),
        sentence_factory.build("b")
      ]
      model = { "b" => false }

      expect(described_class.new(nil, nil).find_unit_clause(clauses, model)).to eq ["a", false]
    end

    it do
      clauses = [
        sentence_factory.build(:not, "a", :or, "b"),
        sentence_factory.build(:not, "b"),
        sentence_factory.build("a")
      ]
      model = { "b" => false, "a" => true }

      expect(described_class.new(nil, nil).find_unit_clause(clauses, model)).to eq [nil, nil]
    end

    it do
      clauses = [
        sentence_factory.build(:not, "a", :or, ["b", :or, "c"]),
        sentence_factory.build(:not, "b")
      ]
      model = { "b" => false }

      expect(described_class.new(nil, nil).find_unit_clause(clauses, model)).to eq [nil, nil]
    end
  end

  describe ".run" do
    it do
      kb = RuleRover::PropositionalLogic::KnowledgeBase.new(engine: :backward_chaining)
      kb.assert("a", :then, "b")
      kb.assert("a")
      kb = kb.to_clauses
      query = sentence_factory.build("b")

      expect(described_class.run(kb: kb, query: query)).to be true
    end

    it do
      kb = RuleRover::PropositionalLogic::KnowledgeBase.new(engine: :backward_chaining)
      kb.assert("a", :iff, "b")
      kb.assert("b", :then, "c")
      kb.assert("c", :then, "d")
      kb.assert("d", :then, [:not, "e", :or, "f"])
      kb.assert("a")
      kb.assert("e")
      kb = kb.to_clauses
      query = sentence_factory.build("f")

      expect(described_class.run(kb: kb, query: query)).to be true
    end

    describe "no model satisfies the query" do
      it do
        kb = RuleRover::PropositionalLogic::KnowledgeBase.new(engine: :backward_chaining)
        kb.assert("a", :then, "b")
        kb.assert("a")
        kb.assert(:not, "b")
        kb = kb.to_clauses
        query = sentence_factory.build("b")

        expect(described_class.run(kb: kb, query: query)).to be false
      end

      it do
        kb = RuleRover::PropositionalLogic::KnowledgeBase.new(engine: :backward_chaining)
        kb.assert("a", :then, "b")
        kb.assert("b", :then, "c")
        kb.assert("c", :then, "d")
        kb.assert("a")
        kb.assert(:not, "b")

        kb = kb.to_clauses
        query = sentence_factory.build("f")

        expect(described_class.run(kb: kb, query: query)).to be false
      end
    end
  end

  def sentence_factory
    RuleRover::PropositionalLogic::Sentences::Factory
  end
end
