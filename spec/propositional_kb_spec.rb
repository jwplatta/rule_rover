require 'spec_helper'

describe RuleRover::PropositionalKB do
  describe '.build' do
    it 'creates a new knowledge base from proposition strings'do
      kb = described_class.build("not(A)", "C or D")
      expect(kb.clauses.map(&:to_s)).to eq ["not(A)", "(C or D)"]
    end
    it 'creates a new knowledge base from proposition strings'do
      kb = described_class.build("not(A)", "((B ≡ W) or X)", "C and D")
      expect(kb.clauses.map(&:to_s)).to eq ["not(A)", "((not(B) or W) or X)", "((B or not(W)) or X)", "C", "D"]
    end
  end
  context '#assert' do
    it 'adds an atomic to the KB' do
      prop_kb = RuleRover::PropositionalKB.new
      prop_kb.assert("A")
      prop_kb.assert("B")
      expect(prop_kb.clauses.size).to eq 2
    end
    it 'adds complex statements' do
      prop_kb = RuleRover::PropositionalKB.new
      prop_kb.assert("A or B")
      expect(prop_kb.clauses.first).to eq RuleRover::Statements::Proposition.parse("A or B")
    end
    it 'converts to CNF beforing adding to KB' do
      prop_kb = RuleRover::PropositionalKB.new
      prop_kb.assert("A ⊃ B")
      expect(prop_kb.clauses.first).to eq RuleRover::Statements::Proposition.parse("not(A) or B")
    end
    it 'adding a statement idempotent' do
      prop_kb = RuleRover::PropositionalKB.new
      prop_kb.assert("A or B")
      prop_kb.assert("B or A")
      expect(prop_kb.size).to eq 1
    end
    it 'adding a statement idempotent' do
      prop_kb = RuleRover::PropositionalKB.new
      prop_kb.assert("A or B")
      prop_kb.assert("B or A")
      expect(prop_kb.size).to eq 1
    end
  end
  context '#deny' do
    it 'removes an atomic from KB' do
      prop_kb = RuleRover::PropositionalKB.new
      prop_kb.assert("A")
      expect(prop_kb.clauses.size).to eq 1
      prop_kb.deny("A")
      expect(prop_kb.clauses.size).to eq 0
    end
    context 'removing complex statements' do
      it do
        prop_kb = RuleRover::PropositionalKB.new
        prop_kb.assert("A or B")
        expect(prop_kb.clauses.size).to eq 1
        prop_kb.deny("A or B")
        expect(prop_kb.clauses.size).to eq 0
      end
      it do
        prop_kb = RuleRover::PropositionalKB.new
        prop_kb.assert("(A or B) and C")
        expect(prop_kb.clauses.size).to eq 2
        prop_kb.deny("C and (A or B)")
        expect(prop_kb.clauses.size).to eq 0
      end
      it 'does not add clauses already in the KB' do
        prop_kb = RuleRover::PropositionalKB.new
        prop_kb.assert("(A or B) and C")
        expect(prop_kb.clauses.size).to eq 2
        prop_kb.assert("D and (B or A)")
        expect(prop_kb.clauses.size).to eq 3
      end
    end
  end
  context '#query' do
    it do
      prop_kb = RuleRover::PropositionalKB.build("(A or B) and C")
      aggregate_failures do
        expect(prop_kb.query("C")).to be true
        expect(prop_kb.query("(B or A) and C")).to be true
        expect(prop_kb.query("A or B")).to be true
        expect(prop_kb.query("(A or B) and D")).to be false
      end
    end
  end
end