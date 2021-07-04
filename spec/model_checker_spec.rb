require 'spec_helper'

describe MyKen::ModelChecker do
  describe '.literals' do
    it do
      a = MyKen::Statements::Statement.new("A")
      b = MyKen::Statements::Statement.new("B")
      c = MyKen::Statements::Statement.new("C")
      d = MyKen::Statements::Statement.new("D")

      literals = MyKen::ModelChecker.literals(a.and(b).or(c.not).and(d).and(a.not).or(b))
      expect(literals.count).to eq(4)
    end
  end
  describe '.true_in_model?' do
    it do
      a = MyKen::Statements::Statement.new("A")
      model = {
        "A" => true
      }

      result = MyKen::ModelChecker.true_in_model?(a, model)
      expect(result).to be true
    end
    context 'negation statement' do
      it do
        a = MyKen::Statements::Statement.new("A")
        model = {
          "A" => true
        }

        result = MyKen::ModelChecker.true_in_model?(a.not, model)
        expect(result).to be false
      end
    end
    context 'conjunction statement' do
      it do
        a = MyKen::Statements::Statement.new("A")
        b = MyKen::Statements::Statement.new("B")
        model = {
          "A" => true,
          "B" => false
        }

        result = MyKen::ModelChecker.true_in_model?(a.and(b), model)
        expect(result).to be false
      end
    end
    context 'disjunction statement' do
      it do
        a = MyKen::Statements::Statement.new("A")
        b = MyKen::Statements::Statement.new("B")
        model = {
          "A" => true,
          "B" => false
        }

        result = MyKen::ModelChecker.true_in_model?(a.or(b), model)
        expect(result).to be true
      end
    end
    context 'complex statement' do
      it do
        a = MyKen::Statements::Statement.new("A")
        b = MyKen::Statements::Statement.new("B")
        c = MyKen::Statements::Statement.new("C")
        d = MyKen::Statements::Statement.new("D")
        model = {
          "A" => true,
          "B" => false,
          "C" => false,
          "D" => true
        }

        stmt = a.or(b).and(c.or(d.not))
        # True and False => False
        result = MyKen::ModelChecker.true_in_model?(stmt, model)
        expect(result).to be false
      end
    end
  end
  describe '.entail?' do
    it do
      a = MyKen::Statements::Statement.new("A")
      b = MyKen::Statements::Statement.new("B")

      prop_kb = MyKen::PropositionalKB.new
      prop_kb.assert(a.⊃(b))
      prop_kb.assert(a)

      expect(MyKen::ModelChecker.entail?(prop_kb, b)).to be true
    end
    it do
      a = MyKen::Statements::Statement.new("A")
      b = MyKen::Statements::Statement.new("B")

      prop_kb = MyKen::PropositionalKB.new
      prop_kb.assert(a.⊃(b))
      prop_kb.assert(b.not)

      expect(MyKen::ModelChecker.entail?(prop_kb, a.not)).to be true
    end
    it do
      a = MyKen::Statements::Statement.new("A")
      b = MyKen::Statements::Statement.new("B")
      c = MyKen::Statements::Statement.new("C")

      prop_kb = MyKen::PropositionalKB.new
      prop_kb.assert(a.⊃(b))
      prop_kb.assert(b.⊃(c))
      prop_kb.assert(a)

      expect(MyKen::ModelChecker.entail?(prop_kb, c)).to be true
    end
    it do
      a = MyKen::Statements::Statement.new("A")
      b = MyKen::Statements::Statement.new("B")
      c = MyKen::Statements::Statement.new("C")

      prop_kb = MyKen::PropositionalKB.new
      prop_kb.assert(a.⊃(b))
      prop_kb.assert(b.⊃(c))
      prop_kb.assert(c.not)

      expect(MyKen::ModelChecker.entail?(prop_kb, a.not)).to be true
    end
  end
  context 'simple knowledge base' do
    let(:as1) do
      MyKen::Statements::AtomicStatement.new(true, "as1")
    end
    let(:as2) do
      MyKen::Statements::AtomicStatement.new(true, "as2")
    end
    let(:statements) do
      [
        as1,
        as2,
        cs1 = MyKen::Statements::ComplexStatement.new(as1, as2, '⊃')
      ]
    end
    let(:cs2) do
      not_as2 = MyKen::Statements::ComplexStatement.new(as2, nil, 'not')
      MyKen::Statements::ComplexStatement.new(as1, not_as2, 'and')
    end
    let(:kb) do
      MyKen::KnowledgeBase.new do |kb|
        statements.each { |s| kb.add_fact(s) }
      end
    end
    context 'KB entails alpha' do
      it 'returns true' do
        expect(MyKen::ModelChecker.run(kb, as2)).to be true
      end
    end
    context 'KB does not entail alpha' do
      it 'returns false' do
        expect(MyKen::ModelChecker.run(kb, cs2)).to be false
      end
    end
  end
end
