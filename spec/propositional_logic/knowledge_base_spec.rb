require 'spec_helper'

describe RuleRover::PropositionalLogic::KnowledgeBase do
  it 'does not raise' do
    expect { described_class.new }.not_to raise_error
  end
  describe '#connectives' do
    it do
      expect(subject.connectives).to eq RuleRover::PropositionalLogic::CONNECTIVES
    end
  end
  describe '#operators' do
    it do
      expect(subject.operators).to eq RuleRover::PropositionalLogic::OPERATORS
    end
  end
  describe '#assert' do
    it 'it saves a set of sentences' do
      subject.assert("a", :and, "b")
      subject.assert("a", :and, "b")
      expect(subject.sentences.size).to eq 1
    end
    it 'saves a set of symbols' do
      subject.assert("a", :and, "b")
      subject.assert("a", :or, "c")
      subject.assert("d", :then, "b")
      expect(subject.symbols).to eq(Set.new(["a", "b", "c", "d"]))
    end
  end
  describe '#to_cnf' do
    it do
      subject.assert("a", :iff, "b")
      subject.assert("a", :and, "f")
      subject.assert("c", :then, "d")
      subject.assert("e", :and, "f")
      new_kb = subject.to_clauses

      expected = [
        sentence_factory.build([:not, "a"], :or, "b"),
        sentence_factory.build("f"),
        sentence_factory.build([:not, "b"], :or, "a"),
        sentence_factory.build("a"),
        sentence_factory.build([:not, "c"], :or, "d"),
        sentence_factory.build("e"),
      ]
      expect(new_kb.sentences).to match_array(expected)
    end
  end

  describe '#is_definite?' do
    describe 'when all clauses are definite' do
      it do
        subject.assert("a", :iff, "b")
        subject.assert("a", :and, "f")
        subject.assert("c", :then, "d")
        subject.assert("e", :and, "f")
        new_kb = subject.to_clauses
        expect(new_kb.is_definite?).to be true
      end
    end
    describe 'when some clauses are not definite' do
      it do
        subject.assert("a", :iff, "b")
        subject.assert(:not, "a", :and, :not, "f")
        subject.assert("c", :then, "d")
        subject.assert("e", :and, "f")
        new_kb = subject.to_clauses
        expect(new_kb.is_definite?).to be false
      end
    end
    describe '#entail?' do
      describe 'model_checking' do
        it do
          kb = RuleRover::PropositionalLogic::KnowledgeBase.new(engine: :model_checking)
          kb.assert("a", :then, "b")
          kb.assert("a")
          expect(kb.entail?("b")).to be true
        end
      end
      describe 'resolution' do
        it do
          kb = RuleRover::PropositionalLogic::KnowledgeBase.new(engine: :resolution)
          kb.assert("a", :then, "b")
          kb.assert("a")
          expect(kb.entail?("b")).to be true
        end
      end
      describe 'forward_chaining' do
        it do
          kb = RuleRover::PropositionalLogic::KnowledgeBase.new(engine: :forward_chaining)
          kb.assert("a", :then, "b")
          kb.assert("a")

          expect(kb.entail?("b")).to be true
        end
        describe 'when query is not a single symbol' do
          it 'raises' do
            kb = RuleRover::PropositionalLogic::KnowledgeBase.new(engine: :forward_chaining)
            kb.assert("a", :then, "b")
            kb.assert("a")

            expect { kb.entail?("b", :or, "b") }.to raise_error(
              RuleRover::PropositionalLogic::QueryNotSinglePropositionSymbol
            )
          end
        end
        describe 'when knowledge base is not definite' do
          it 'raises' do
            kb = RuleRover::PropositionalLogic::KnowledgeBase.new(engine: :forward_chaining)
            kb.assert("a", :then, :not, "b")
            kb.assert("a")
            expect { kb.entail?("b") }.to raise_error(
              RuleRover::PropositionalLogic::KnowledgeBaseNotDefinite
            )
          end
        end
      end
      describe 'backward_chaining' do
        it do
          kb = RuleRover::PropositionalLogic::KnowledgeBase.new(engine: :backward_chaining)
          kb.assert("a", :then, "b")
          kb.assert("a")

          expect(kb.entail?("b")).to be true
        end
        it do
          kb = RuleRover::PropositionalLogic::KnowledgeBase.new(engine: :backward_chaining)
          kb.assert("a", :iff, "b")
          kb.assert("b", :then, "c")
          kb.assert("c", :then, "d")
          kb.assert("d", :then, [:not, "e", :or, "f"])
          kb.assert("a")
          kb.assert("e")

          expect(kb.entail?("f")).to be true
        end
      end
    end
  end

  def sentence_factory
    RuleRover::PropositionalLogic::Sentences::Factory
  end
end