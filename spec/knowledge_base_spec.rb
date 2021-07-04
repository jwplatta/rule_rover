require 'spec_helper'

describe MyKen::KnowledgeBase do
  let(:statements) do
    [
      as1 = MyKen::Statements::AtomicStatement.new(true, :as1),
      as2 = MyKen::Statements::AtomicStatement.new(false, :as2),
      as3 = MyKen::Statements::AtomicStatement.new(false, :as3),
      cs1 = MyKen::Statements::ComplexStatement.new(as1, as2, 'and'),
      cs2 = MyKen::Statements::ComplexStatement.new(as1, as3, 'or'),
      cs3 = MyKen::Statements::ComplexStatement.new(cs1, cs2, 'or')
    ]
  end
  let(:kb) do
    described_class.new do |kb|
      statements.each { |s| kb.add_fact(s) }
    end
  end
  describe '#initialize' do
    it do
      expect(kb.statements.count).to eq statements.count
      expect(kb.atomic_statements.count).to eq 3
    end
  end

  describe '#to_s' do
    it do
      expect(kb.to_s).to eq "as1: true\nas2: false\nas3: false\n(as1 and as2)\n(as1 or as3)\n((as1 and as2) or (as1 or as3))"
    end
  end

  describe '#update_model' do
    it 'changes values of atomic statements' do
      new_model = [false, true, true]
      kb.update_model(*new_model)

      expect(kb.atomic_statements.map(&:value)).to eq new_model
    end
  end

  describe '#value' do
    it 'returns true' do
      new_model = [false, false, false]
      kb.update_model(*new_model)
      expect(kb.value).to be false
    end

    it 'returns false' do
      new_model = [true, true, true]
      kb.update_model(*new_model)
      expect(kb.value).to be true
    end
  end

  describe 'propositional knowledge base' do
    context '#assert' do
      it 'adds an atomic to the KB' do
        a = MyKen::Statements::Statement.new("A")
        b = MyKen::Statements::Statement.new("B")
        prop_kb = MyKen::PropositionalKB.new
        prop_kb.assert(a)
        prop_kb.assert(b)
        expect(prop_kb.clauses.size).to eq 2
      end
      context 'adding complex statements' do
        it do
          a = MyKen::Statements::Statement.new("A")
          b = MyKen::Statements::Statement.new("B")
          prop_kb = MyKen::PropositionalKB.new
          prop_kb.assert(a.or(b))
          expect(prop_kb.clauses.size).to eq 1
        end
        it 'converts to CNF beforing adding to KB' do
          a = MyKen::Statements::Statement.new("A")
          b = MyKen::Statements::Statement.new("B")
          prop_kb = MyKen::PropositionalKB.new
          prop_kb.assert(a.⊃(b))
          expect(prop_kb.clauses.first.to_s).to eq a.not.or(b).to_s
        end
      end
    end
    context '#deny' do
      it 'removes an atomic from KB' do
        a = MyKen::Statements::Statement.new("A")
        prop_kb = MyKen::PropositionalKB.new
        prop_kb.assert(a)
        expect(prop_kb.clauses.size).to eq 1
        prop_kb.deny(a)
        expect(prop_kb.clauses.size).to eq 0
      end
      context 'removing complex statements' do
        it do
          a = MyKen::Statements::Statement.new("A")
          b = MyKen::Statements::Statement.new("B")
          prop_kb = MyKen::PropositionalKB.new
          prop_kb.assert(a.or(b))
          expect(prop_kb.clauses.size).to eq 1
          prop_kb.deny(b.or(a))
          expect(prop_kb.clauses.size).to eq 0
        end
        it do
          a = MyKen::Statements::Statement.new("A")
          b = MyKen::Statements::Statement.new("B")
          c = MyKen::Statements::Statement.new("C")
          prop_kb = MyKen::PropositionalKB.new
          prop_kb.assert(a.or(b).and(c))
          expect(prop_kb.clauses.size).to eq 2
          prop_kb.deny(c.and(b.or(a)))
          expect(prop_kb.clauses.size).to eq 0
        end
        it do
          a = MyKen::Statements::Statement.new("A")
          b = MyKen::Statements::Statement.new("B")
          c = MyKen::Statements::Statement.new("C")
          prop_kb = MyKen::PropositionalKB.new
          prop_kb.assert(a.or(b).and(c))
          expect(prop_kb.clauses.size).to eq 2
          prop_kb.deny(c.and(b.or(a)))
          expect(prop_kb.clauses.size).to eq 0
        end
        it do
          a = MyKen::Statements::Statement.new("A")
          b = MyKen::Statements::Statement.new("B")
          c = MyKen::Statements::Statement.new("C")
          prop_kb = MyKen::PropositionalKB.new
          prop_kb.assert(a.or(b).and(c))
          expect(prop_kb.clauses.size).to eq 2
          prop_kb.deny(c.and(b.or(a)))
          expect(prop_kb.clauses.size).to eq 0
        end
        it 'does not add clauses already in the KB' do
          a = MyKen::Statements::Statement.new("A")
          b = MyKen::Statements::Statement.new("B")
          c = MyKen::Statements::Statement.new("C")
          d = MyKen::Statements::Statement.new("D")
          prop_kb = MyKen::PropositionalKB.new
          prop_kb.assert(a.or(b).and(c))
          expect(prop_kb.clauses.size).to eq 2
          prop_kb.assert(d.and(b.or(a)))
          expect(prop_kb.clauses.size).to eq 3
        end
      end
    end
    context '#query' do
      it do
        a = MyKen::Statements::Statement.new("A")
        b = MyKen::Statements::Statement.new("B")
        c = MyKen::Statements::Statement.new("C")
        d = MyKen::Statements::Statement.new("D")
        prop_kb = MyKen::PropositionalKB.new
        prop_kb.assert(a.or(b).and(c))

        expect(prop_kb.query(c)).to be true
        expect(prop_kb.query(a.or(b).and(c))).to be true
        expect(prop_kb.query(a.or(b))).to be true
        expect(prop_kb.query(a.or(b).and(d))).to be false
      end
    end
  end
end
