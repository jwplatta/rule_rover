require 'spec_helper'

describe RuleRover::Statements do
  describe '.definite_clause?' do
    context 'propositional statements' do
      it do
        a = RuleRover::Statements::Statement.new("A")
        b = RuleRover::Statements::Statement.new("B")
        c = RuleRover::Statements::Statement.new("C")
        clause = a.not.or(b.not).or(c)
        expect(RuleRover::Statements.definite_clause?(clause)).to be true
      end
      it do
        a = RuleRover::Statements::Statement.new("A")
        b = RuleRover::Statements::Statement.new("B")
        clause = a.⊃(b)
        expect(RuleRover::Statements.definite_clause?(clause)).to be true
      end
      it do
        a = RuleRover::Statements::Statement.new("A")
        b = RuleRover::Statements::Statement.new("B")
        c = RuleRover::Statements::Statement.new("C")
        clause = a.or(b).or(c)
        expect(RuleRover::Statements.definite_clause?(clause)).to be false
      end
    end
    context 'predicate statements' do
      it do
        a = RuleRover::Statements::Predicate.new(identifier: "A", assignments: { "x" => nil })
        b = RuleRover::Statements::Predicate.new(identifier: "B", assignments: { "x" => nil })
        c = RuleRover::Statements::Predicate.new(identifier: "C", assignments: { "x" => nil })
        clause = a.not.or(b.not).or(c)
        expect(RuleRover::Statements.definite_clause?(clause)).to be true
      end
      it do
        a = RuleRover::Statements::Predicate.new(identifier: "A", assignments: { "x" => nil })
        b = RuleRover::Statements::Predicate.new(identifier: "B", assignments: { "x" => nil })
        clause = a.⊃(b)
        expect(RuleRover::Statements.definite_clause?(clause)).to be true
      end
      it do
        a = RuleRover::Statements::Predicate.new(identifier: "A", assignments: { "x" => nil })
        b = RuleRover::Statements::Predicate.new(identifier: "B", assignments: { "x" => nil })
        c = RuleRover::Statements::Predicate.new(identifier: "C", assignments: { "x" => nil })
        clause = a.or(b).or(c)
        expect(RuleRover::Statements.definite_clause?(clause)).to be false
      end
    end
  end
  describe 'ComplexTerm class' do
    it do
      ct = RuleRover::Statements::ComplexTerm.new(identifier: "Test", assignments: {"a" => "Foobar"})
      expect(ct.to_s).to eq "Test[Foobar]"
    end
    it do
      ct = RuleRover::Statements::ComplexTerm.new(identifier: "Test")
      expect(ct.to_s).to eq "Test[x]"
    end
    it do
      ct1 = RuleRover::Statements::ComplexTerm.new(identifier: "Test")
      ct2 = RuleRover::Statements::ComplexTerm.new(identifier: "Test")
      expect(ct1).to eq ct2
    end
  end
  describe 'Predicate class' do
    it do
      predicate = RuleRover::Statements::Predicate.new(
        identifier: "Friendship",
        assignments: { "a" => "Petey", "b" => nil, "c" => "Robby" }
      )
      expect(predicate.identifier).to eq "Friendship"
      expect(predicate.variables).to eq ["a", "b", "c"]
      expect(predicate.constants).to eq ["Petey", "Robby"]
      expect(predicate.arity).to eq 3
    end
    describe '#to_s' do
      it do
        predicate = RuleRover::Statements::Predicate.new(identifier: "Friendship", assignments: { "a" => "Petey", "x" => nil, "c" => "Robby" })
        expect(predicate.to_s).to eq "Friendship(Petey, x, Robby)"
      end
    end
    describe '#substitution' do
      context 'predicate statements' do
        it do
          a = RuleRover::Statements::Predicate.new(identifier: "A", assignments: { "x" => nil, "y" => nil })
          assignments = { "x" => "Harold", "y" => "Maude" }
          new_predicate = a.substitute(assignments)

          expect(new_predicate.to_s).to eq "A(Harold, Maude)"
        end
      end
      context 'empty assignment' do
        it do
          pred = RuleRover::Statements::Predicate.new(identifier: "A", assignments: { "x" => "X", "y" => "Y" })
          new_pred = pred.substitute({})
          expect(new_pred).to eq pred
        end
      end
    end
  end
  describe '.occurs?' do
    it do
      predicate = RuleRover::Statements::Predicate.new(identifier: "Characters", assignments: { "a" => nil, "b" => nil })
      result = RuleRover::Statements.occurs?("x", predicate, {})
      expect(result).to be false
    end
    it do
      predicate = RuleRover::Statements::Predicate.new(identifier: "Characters", assignments: { "a" => nil, "b" => nil })
      result = RuleRover::Statements.occurs?("a", predicate, {})
      expect(result).to be true
    end
    it do
      predicate_x = RuleRover::Statements::Predicate.new(identifier: "Characters", assignments: { "a" => nil, "b" => nil })
      predicate_y = RuleRover::Statements::Predicate.new(identifier: "Villian", assignments: { "z" => nil })
      result = RuleRover::Statements.occurs?("z", predicate_x.and(predicate_y), {})
      expect(result).to be true
    end
    it do
      predicate_x = RuleRover::Statements::Predicate.new(identifier: "Characters", assignments: { "a" => nil, "b" => nil })
      predicate_y = RuleRover::Statements::Predicate.new(identifier: "Villian", assignments: { "z" => nil })
      result = RuleRover::Statements.occurs?("w", predicate_x.and(predicate_y), {})
      expect(result).to be false
    end
    context 'propositional statements' do
      it do
        a = RuleRover::Statements::Statement.new("A")
        b = RuleRover::Statements::Statement.new("B")
        result = RuleRover::Statements.occurs?("d", a.and(b), {})
        expect(result).to be false
      end
    end
    context 'assigned constants' do
      it do
        const = RuleRover::Statements::Statement.new("Harold")
        result = RuleRover::Statements.occurs?("z", const, { "z" => "Harold" })
        expect(result).to be true
      end
      it do
        const = RuleRover::Statements::Statement.new("Harold")
        result = RuleRover::Statements.occurs?("z", const, { "x" => "Harold" })
        expect(result).to be false
      end
    end
  end
  describe '.standardize_apart' do
    it do
      predicate_x = RuleRover::Statements::Predicate.new(identifier: "Knows", assignments: { "x" => "Mary", "y" => nil })
      predicate_y = RuleRover::Statements::Predicate.new(identifier: "Knows", assignments: { "w" => nil, "x" => "Harry" })
      result = RuleRover::Statements.standardize_apart(predicate_x, predicate_y)
      expect(result.map { |stmt| stmt.variables }.flatten).to eq ["a", "b", "c", "d"]
    end
  end
  describe '.unify' do
    context 'variables and constants' do
      it do
        var_x = "x"
        var_y = "y"
        assignment = { "x" => "Harold" }
        result = RuleRover::Statements.unify(var_x, var_y, assignment)
        expect(result).to eq({ "x" => "Harold", "y" => "Harold" })
      end
      it do
        var_x = "x"
        var_y = "y"
        assignments = { "z" => "Harold" }
        result = RuleRover::Statements.unify(var_x, var_y, assignments)
        expect(result).to eq({ "x" => "y", "z" => "Harold" })
      end
      it do
        var_x = "x"
        const_y = "Y"
        result = RuleRover::Statements.unify(var_x, const_y, {})
        expect(result).to eq({ "x" => "Y" })
      end
      it do
        const_x = "X"
        const_y = "Y"
        result = RuleRover::Statements.unify(const_x, const_y, {})
        expect(result).to eq(nil)
      end
    end
    context 'predicates' do
      it do
        predicate_x = RuleRover::Statements::Predicate.new(identifier: "Protagonist", assignments: { "x" => nil })
        predicate_y = RuleRover::Statements::Predicate.new(identifier: "Antagonist", assignments: { "y" => "Harold" })
        result = RuleRover::Statements.unify(predicate_x, predicate_y, {})
        expect(result).to eq({})
      end
      it do
        predicate_x = RuleRover::Statements::Predicate.new(identifier: "Protagonist", assignments: { "x" => nil })
        predicate_y = RuleRover::Statements::Predicate.new(identifier: "Protagonist", assignments: { "y" => "Harold" })
        result = RuleRover::Statements.unify(predicate_x, predicate_y, {})
        expect(result).to eq({ "x" => "Harold", "y" => "Harold" })
      end
      it do
        predicate_x = RuleRover::Statements::Predicate.new(identifier: "Protagonist", assignments: { "x" => "Maude" })
        predicate_y = RuleRover::Statements::Predicate.new(identifier: "Protagonist", assignments: { "y" => "Harold" })
        result = RuleRover::Statements.unify(predicate_x, predicate_y, {})
        expect(result).to eq({})
      end
      it do
        predicate_x = RuleRover::Statements::Predicate.new(identifier: "Enemy", assignments: { "x" => "Maude", "z" => nil })
        predicate_y = RuleRover::Statements::Predicate.new(identifier: "Enemy", assignments: { "y" => nil, "w" => "Harold" })
        result = RuleRover::Statements.unify(predicate_x, predicate_y, {})
        expect(result).to eq({ "x" => "Maude", "y" => "Maude", "z" => "Harold", "w" => "Harold" })
      end
      it do
        predicate_x = RuleRover::Statements::Predicate.new(identifier: "Knows", assignments: { "x" => "John", "z" => nil })
        predicate_y = RuleRover::Statements::Predicate.new(identifier: "Knows", assignments: { "y" => "John", "w" => "Jane" })
        result = RuleRover::Statements.unify(predicate_x, predicate_y, {})
        expect(result).to eq({ "x" => "John", "y" => "John", "z" => "Jane", "w" => "Jane" })
      end
      it do
        predicate_x = RuleRover::Statements::Predicate.new(identifier: "Knows", assignments: { "x" => "John", "z" => nil })
        predicate_y = RuleRover::Statements::Predicate.new(identifier: "Knows", assignments: { "y" => nil, "w" => "Bill" })
        result = RuleRover::Statements.unify(predicate_x, predicate_y, {})
        expect(result).to eq({ "x" => "John", "y" => "John", "z" => "Bill", "w" => "Bill" })
      end
    end
    context 'statements' do
      it do
        predicate_x = RuleRover::Statements::Predicate.new(identifier: "Protagonist", assignments: { "x" => "Batman" })
        predicate_y = RuleRover::Statements::Predicate.new(identifier: "Antagonist", assignments: { "y" => "Joker" })
        predicate_z = RuleRover::Statements::Predicate.new(identifier: "Protagonist", assignments: { "z" => nil })
        predicate_w = RuleRover::Statements::Predicate.new(identifier: "Antagonist", assignments: { "w" => nil })

        result = RuleRover::Statements.unify(predicate_x.and(predicate_y), predicate_z.and(predicate_w), {})
        expect(result).to eq({ "x" => "Batman", "y" => "Joker", "z" => "Batman", "w" => "Joker" })
      end
      it do
        predicate_x = RuleRover::Statements::Predicate.new(identifier: "Protagonist", assignments: { "x" => "Batman" })
        predicate_y = RuleRover::Statements::Predicate.new(identifier: "Antagonist", assignments: { "y" => "Joker" })
        predicate_z = RuleRover::Statements::Predicate.new(identifier: "Protagonist", assignments: { "z" => nil })
        predicate_w = RuleRover::Statements::Predicate.new(identifier: "Antagonist", assignments: { "w" => nil })
        result = RuleRover::Statements.unify(predicate_x.and(predicate_y), predicate_w.and(predicate_z), {})
        expect(result).to eq({})
      end
      it do
        predicate_x = RuleRover::Statements::Predicate.new(identifier: "Protagonist", assignments: { "x" => "Batman" })
        predicate_y = RuleRover::Statements::Predicate.new(identifier: "Enemy", assignments: { "y" => "Joker" })
        predicate_z = RuleRover::Statements::Predicate.new(identifier: "Enemy", assignments: { "z" => "Penguin" })
        predicate_a = RuleRover::Statements::Predicate.new(identifier: "Protagonist", assignments: { "a" => nil })
        predicate_b = RuleRover::Statements::Predicate.new(identifier: "Enemy", assignments: { "b" => nil })
        predicate_c = RuleRover::Statements::Predicate.new(identifier: "Enemy", assignments: { "c" => nil })

        result = RuleRover::Statements.unify(
          predicate_x.and(predicate_y).and(predicate_z),
          predicate_a.and(predicate_b).and(predicate_c),
          {}
        )

        expect(result).to eq({ "x" => "Batman", "y" => "Joker", "z" => "Penguin", "a" => "Batman", "b" => "Joker", "c" => "Penguin" })
      end
      it do
        predicate_x = RuleRover::Statements::Predicate.new(identifier: "Protagonist", assignments: { "x" => "Batman" })
        predicate_y = RuleRover::Statements::Predicate.new(identifier: "Antagonist", assignments: { "y" => nil })
        predicate_z = RuleRover::Statements::Predicate.new(identifier: "Protagonist", assignments: { "z" => nil })
        predicate_w = RuleRover::Statements::Predicate.new(identifier: "Antagonist", assignments: { "w" => "Joker" })

        result = RuleRover::Statements.unify(predicate_x.and(predicate_y), predicate_z.and(predicate_w), {})
        expect(result).to eq({ "x" => "Batman", "y" => "Joker", "z" => "Batman", "w" => "Joker" })
      end
      it do
        predicate_x = RuleRover::Statements::Predicate.new(identifier: "Protagonist", assignments: { "x" => "Batman" })
        predicate_y = RuleRover::Statements::Predicate.new(identifier: "Antagonist", assignments: { "y" => "Penguin" })
        predicate_z = RuleRover::Statements::Predicate.new(identifier: "Protagonist", assignments: { "z" => nil })
        predicate_w = RuleRover::Statements::Predicate.new(identifier: "Antagonist", assignments: { "w" => "Joker" })

        result = RuleRover::Statements.unify(predicate_x.and(predicate_y), predicate_z.and(predicate_w), {})
        expect(result).to eq({})
      end
      it do
        predicate_x = RuleRover::Statements::Predicate.new(identifier: "Protagonist", assignments: { "x" => "Batman" })
        predicate_y = RuleRover::Statements::Predicate.new(identifier: "Antagonist", assignments: { "y" => "Joker" })
        predicate_z = RuleRover::Statements::Predicate.new(identifier: "Protagonist", assignments: { "z" => nil })
        predicate_w = RuleRover::Statements::Predicate.new(identifier: "Antagonist", assignments: { "w" => nil })

        result = RuleRover::Statements.unify(
          predicate_x.and(predicate_y),
          predicate_z.or(predicate_w),
          {}
        )
        expect(result).to eq({})
      end
    end
  end
  describe '.substitute' do
    it do
      a = RuleRover::Statements::Predicate.new(identifier: "Characters", assignments: { "x" => nil, "y" => nil })
      b = RuleRover::Statements::Predicate.new(identifier: "Music", assignments: { "z" => nil })
      stmt = a.and(b)

      assignments = { "x" => "Harold", "y" => "Maude", "z" => "CatStevens" }
      result = RuleRover::Statements.substitute(stmt, assignments)
      expect(result.to_s).to eq "(Characters(Harold, Maude) and Music(CatStevens))"
    end
    it do
      a = RuleRover::Statements::Predicate.new(identifier: "Characters", assignments: { "x" => nil, "y" => nil })
      b = RuleRover::Statements::Predicate.new(identifier: "Music", assignments: { "z" => nil })
      stmt = a.and(b.not)

      assignments = { "x" => "Harold", "y" => "Maude", "z" => "CatStevens" }
      result = RuleRover::Statements.substitute(stmt, assignments)
      expect(result.to_s).to eq "(Characters(Harold, Maude) and not(Music(CatStevens)))"
    end
    it do
      a = RuleRover::Statements::Predicate.new(identifier: "Characters", assignments: { "x" => nil, "y" => nil})
      b = RuleRover::Statements::Predicate.new(identifier: "Music", assignments: { "z" => nil })
      stmt = a.or(b.not)

      assignments = { "x" => "Harold", "y" => "Maude", "z" => "CatStevens", "w" => "Colin Higgins" }
      result = RuleRover::Statements.substitute(stmt, assignments)
      expect(result.to_s).to eq "(Characters(Harold, Maude) or not(Music(CatStevens)))"
    end
    it do
      a = RuleRover::Statements::Predicate.new(identifier: "Characters", assignments: { "x" => nil, "y" => nil})
      b = RuleRover::Statements::Predicate.new(identifier: "Music", assignments: { "z" => nil })
      c = RuleRover::Statements::Statement.new("C")
      stmt = a.or(b.not).and(c)

      assignments = { "x" => "Harold", "y" => "Maude", "z" => "CatStevens", "w" => "Colin Higgins" }
      result = RuleRover::Statements.substitute(stmt, assignments)
      expect(result.to_s).to eq "((Characters(Harold, Maude) or not(Music(CatStevens))) and C)"
    end
    it do
      ct_a = RuleRover::Statements::ComplexTerm.new(identifier: "Guitar", assignments: { "x" => nil })
      ct_b = RuleRover::Statements::ComplexTerm.new(identifier: "Music", assignments: { "y" => nil })

      stmt = ct_a.and(ct_b)

      assignments = { "x" => "CatStevens", "y" => "CatStevens" }

      result = RuleRover::Statements.substitute(stmt, assignments)
      expect(result.to_s).to eq "(Guitar[CatStevens] and Music[CatStevens])"
    end
  end
  describe 'Statement class' do
    context 'atomic statements' do
      it do
        aggregate_failures do
          expect(RuleRover::Statements::Statement.new("A").to_s).to eq "A"
          expect do
            RuleRover::Statements::Statement.new("and")
          end.to raise_error(ArgumentError)
        end
      end
    end
    describe '#variables' do
      it do
        predicate_x = RuleRover::Statements::Predicate.new(identifier: "Protagonist", assignments: { "x" => "Batman" })
        predicate_y = RuleRover::Statements::Predicate.new(identifier: "Antagonist", assignments: { "x" => nil })
        predicate_z = RuleRover::Statements::Predicate.new(identifier: "SelfSabotage", assignments: { "c" => nil, "d" => nil })
        stmt = predicate_x.and(predicate_y).or(predicate_z)
        expect(stmt.variables.sort).to eq ["c", "d", "x"]
      end
    end
    describe '#==' do
      it 'returns true for two atomics' do
        x = RuleRover::Statements::Statement.new("A")
        y = RuleRover::Statements::Statement.new("A")
        expect(x == y).to be true
      end
      it 'returns true for negation of two atomics' do
        x = RuleRover::Statements::Statement.new("A")
        y = RuleRover::Statements::Statement.new("A")
        expect(x.not == y.not).to be true
      end
      it 'returns true for negation of two atomics' do
        a = RuleRover::Statements::Statement.new("A")
        b = RuleRover::Statements::Statement.new("B")
        c = RuleRover::Statements::Statement.new("C")

        expect(a.or(b).or(c) == c.or(a).or(b)).to be true
      end
      it 'returns true long sentence with conjuncts and disjuncts' do
        a = RuleRover::Statements::Statement.new("A")
        b = RuleRover::Statements::Statement.new("B")
        d = RuleRover::Statements::Statement.new("D")
        expect(a.or(b).and(b.or(d.not)) == d.not.or(b).and(b.or(a))).to be true
      end
      it 'returns true long sentence with conditionals and biconditionals' do
        a = RuleRover::Statements::Statement.new("A")
        b = RuleRover::Statements::Statement.new("B")
        c = RuleRover::Statements::Statement.new("C")
        d = RuleRover::Statements::Statement.new("D")

        expect(a.≡(b).and(c.⊃(d.or(a))) == b.≡(a).and(c.⊃(a.or(d)))).to be true
      end
      it 'returns true for two disjunctions in different order' do
        a = RuleRover::Statements::Statement.new("A")
        b = RuleRover::Statements::Statement.new("B")
        expect(a.or(b) == b.or(a)).to be true
      end
      it 'returns true for two conjunctions in different order' do
        a = RuleRover::Statements::Statement.new("A")
        b = RuleRover::Statements::Statement.new("B")
        expect(a.and(b) == b.and(a)).to be true
      end
      it 'returns true for two conjunctions in different order' do
        a = RuleRover::Statements::Statement.new("A")
        b = RuleRover::Statements::Statement.new("B")
        expect(a.and(b) == b.and(a)).to be true
      end
    end
    context 'complex statements' do
      it do
        aggregate_failures do
          a = RuleRover::Statements::Statement.new("A")
          b = RuleRover::Statements::Statement.new("B")
          c = RuleRover::Statements::Statement.new("C")
          d = RuleRover::Statements::Statement.new("D")

          not_d = d.not
          a_and_b = a.and(b)
          c_or_a_and_b = c.or(a_and_b)
          not_d_cond_c_or_a_and_b = not_d.⊃(c_or_a_and_b)
          c_bicond_d = c.≡(d)

          expect(not_d.to_s).to eq "not(D)"
          expect(a_and_b.to_s).to eq "(A and B)"
          expect(c_or_a_and_b.to_s).to eq "(C or (A and B))"
          expect(not_d_cond_c_or_a_and_b.to_s).to eq "(not(D) ⊃ (C or (A and B)))"
          expect(c_bicond_d.to_s).to eq "(C ≡ D)"
        end
      end
    end
    describe '.conjuncts' do
      context 'propositions' do
        it do
          a = RuleRover::Statements::Statement.new("A")
          b = RuleRover::Statements::Statement.new("B")
          c = RuleRover::Statements::Statement.new("C")
          a_and_b_and_c = a.and(b).and(c)

          result = RuleRover::Statements.conjuncts(a_and_b_and_c)
          expect(result).to eq([a, b, c])
        end
        it do
          a = RuleRover::Statements::Statement.new("A")
          b = RuleRover::Statements::Statement.new("B")
          c = RuleRover::Statements::Statement.new("C")
          d = RuleRover::Statements::Statement.new("D")
          a_or_b_and_c_or_d = a.or(b).and(c.or(d))

          result = RuleRover::Statements.conjuncts(a_or_b_and_c_or_d)
          expect(result.map(&:to_s)).to eq([a.or(b).to_s, c.or(d).to_s])
        end
        it do
          a = RuleRover::Statements::Statement.new("A")
          b = RuleRover::Statements::Statement.new("B")
          c = RuleRover::Statements::Statement.new("C")
          d = RuleRover::Statements::Statement.new("D")
          e = RuleRover::Statements::Statement.new("E")
          f = RuleRover::Statements::Statement.new("F")

          a_or_b_and_c_and_d_or_e_or_f = a.or(b).and(c.and(d).and(e.or(f)))
          result = RuleRover::Statements.conjuncts(a_or_b_and_c_and_d_or_e_or_f)
          expect(result.map(&:to_s)).to eq([a.or(b).to_s, c.to_s, d.to_s, e.or(f).to_s])
        end
      end
      context 'predicates' do
        it do
          a = RuleRover::Statements::Predicate.new(identifier: "A", assignments: { "x" => nil })
          b = RuleRover::Statements::Predicate.new(identifier: "B", assignments: { "y" => nil })
          c = RuleRover::Statements::Predicate.new(identifier: "C", assignments: { "a" => "Matt", "b" => "Ben", "c" => "Joe" })
          a_and_b_and_c = a.and(b).and(c)

          result = RuleRover::Statements.conjuncts(a_and_b_and_c)
          expect(result).to eq([a, b, c])
        end
      end
    end
    describe '.disjuncts' do
      context 'propositions' do
        it do
          a = RuleRover::Statements::Statement.new("A")
          b = RuleRover::Statements::Statement.new("B")
          c = RuleRover::Statements::Statement.new("C")
          a_or_b_or_c = a.or(b).or(c)

          result = RuleRover::Statements.disjuncts(a_or_b_or_c)
          expect(result.map(&:to_s)).to eq([a.to_s, b.to_s, c.to_s])
        end
        it do
          a = RuleRover::Statements::Statement.new("A")
          b = RuleRover::Statements::Statement.new("B")
          c = RuleRover::Statements::Statement.new("C")
          d = RuleRover::Statements::Statement.new("D")

          a_or_b_or_c_or_not_d = a.or(b).or(c.or(d.not))
          result = RuleRover::Statements.disjuncts(a_or_b_or_c_or_not_d)
          expect(result.map(&:to_s)).to eq([a.to_s, b.to_s, c.to_s, d.not.to_s])
        end
      end
      context 'predicates' do
        it do
          a = RuleRover::Statements::Predicate.new(identifier: "A", assignments: { "x" => nil })
          b = RuleRover::Statements::Predicate.new(identifier: "B", assignments: { "y" => nil })
          c = RuleRover::Statements::Predicate.new(identifier: "C", assignments: { "a" => "Matt", "b" => "Ben", "c" => "Joe" })
          a_or_b_or_c = a.or(b).or(c)

          result = RuleRover::Statements.disjuncts(a_or_b_or_c)
          expect(result).to eq([a, b, c])
        end
      end
    end
    describe 'conjunctive normal form' do
      context 'complex propositions' do
        context '.to_conjunctive_normal_form' do
          it do
            a = RuleRover::Statements::Statement.new("A")
            b = RuleRover::Statements::Statement.new("B")
            c = RuleRover::Statements::Statement.new("C")
            d = RuleRover::Statements::Statement.new("D")

            not_a_or_b_or_c_bicond_d = a.or(b).not.or(c.≡(d))
            # "(not(A or B) or (C ≡ D))"
            # (not(A) and not(B)) or ((C ⊃ D) and (D ⊃ C))
            # (not(A) and not(B)) or ((not(C) or D) and (not(D) or C))
            # "((not(A) and not(B)) or ((not(C) or D) and (not(D) or C)))"
            # (not(A) or ((not(C) or D) and (not(D) or C))) and (not(B) or ((not(C) or D) and (not(D) or C)))
            # (not(A) or (not(C) or D)) and (not(A) or (not(D) or C)) and (not(B) or (not(C) or D)) and (not(B) or (not(D) or C))

            result = RuleRover::Statements.to_conjunctive_normal_form(not_a_or_b_or_c_bicond_d)

            expect(result.to_s).to eq("(((not(A) or (not(C) or D)) and (not(A) or (not(D) or C))) and ((not(B) or (not(C) or D)) and (not(B) or (not(D) or C))))")
          end
        end
        context '.eliminates_biconditionals' do
          it do
            a = RuleRover::Statements::Statement.new("A")
            b = RuleRover::Statements::Statement.new("B")
            c = RuleRover::Statements::Statement.new("C")
            b_bicond_c = b.≡(c)
            a_bicond_b = a.≡(b_bicond_c)
            result = RuleRover::Statements.eliminate_biconditionals(a_bicond_b)
            expect(result.to_s).to eq("((A ⊃ ((B ⊃ C) and (C ⊃ B))) and (((B ⊃ C) and (C ⊃ B)) ⊃ A))")
          end
        end
        context '.eliminates_conditionals' do
          it do
            a = RuleRover::Statements::Statement.new("A")
            b = RuleRover::Statements::Statement.new("B")
            c = RuleRover::Statements::Statement.new("C")
            b_cond_c = b.⊃(c)
            a_cond_b = a.⊃(b_cond_c)

            result = RuleRover::Statements.eliminate_conditionals(a_cond_b)
            expect(result.to_s).to eq("(not(A) or (not(B) or C))")
          end
        end
        context '.move_negation_to_literals' do
          it 'eliminates double negation of atomic' do
            not_not_a = RuleRover::Statements::Statement.new("A").not.not
            result = RuleRover::Statements.move_negation_to_literals(not_not_a)
            expect(result.to_s).to eq "A"
          end
          it 'eliminates double negation of complex statement' do
            a = RuleRover::Statements::Statement.new("A")
            b = RuleRover::Statements::Statement.new("B")
            not_not_a_and_b = a.and(b).not.not
            result = RuleRover::Statements.move_negation_to_literals(not_not_a_and_b)
            expect(result.to_s).to eq "(A and B)"
          end
          it do
            b = RuleRover::Statements::Statement.new("B")
            c = RuleRover::Statements::Statement.new("C")
            b_or_c = b.or(c)
            not_b_or_c = b_or_c.not
            result = RuleRover::Statements.move_negation_to_literals(not_b_or_c)
            expect(result.to_s).to eq("(not(B) and not(C))")
          end
          it do
            a = RuleRover::Statements::Statement.new("A")
            not_a = a.not
            b = RuleRover::Statements::Statement.new("B")
            c = RuleRover::Statements::Statement.new("C")
            b_or_c = b.or(c)
            not_b_or_c = b_or_c.not
            not_not_b_or_c_and_not_a = not_b_or_c.and(not_a).not
            result = RuleRover::Statements.move_negation_to_literals(not_not_b_or_c_and_not_a)
            expect(result.to_s).to eq("((B or C) or A)")
          end
          it do
            a = RuleRover::Statements::Statement.new("A")
            not_a = a.not
            b = RuleRover::Statements::Statement.new("B")
            c = RuleRover::Statements::Statement.new("C")
            b_or_c = b.or(c)
            not_b_or_c_and_not_a = b_or_c.and(not_a).not
            result = RuleRover::Statements.move_negation_to_literals(not_b_or_c_and_not_a)
            expect(result.to_s).to eq("((not(B) and not(C)) or A)")
          end
        end
        context '.distribute' do
          it do
            a = RuleRover::Statements::Statement.new("A")
            b = RuleRover::Statements::Statement.new("B")
            c = RuleRover::Statements::Statement.new("C")
            a_or_b_and_c = a.or(b.and(c))
            result = RuleRover::Statements.distribute(a_or_b_and_c)
            expect(result.to_s).to eq("((A or B) and (A or C))")
          end
          it do
            a = RuleRover::Statements::Statement.new("A")
            b = RuleRover::Statements::Statement.new("B")
            c = RuleRover::Statements::Statement.new("C")
            d = RuleRover::Statements::Statement.new("D")
            a_and_d_or_b_and_c = a.and(d).or(b.and(c))
            result = RuleRover::Statements.distribute(a_and_d_or_b_and_c)
            # "((A and D) or (B and C))"
            # (A or (B and C)) and (D or (B and C))
            # (((A or B) and (A or C)) and ((D or B) and (D or C)))
            # "(((A or B) and (A or C)) and ((D or B) and (D or C)))"
            expect(result.to_s).to eq("(((A or B) and (A or C)) and ((D or B) and (D or C)))")
          end
        end
      end
      context 'complex propositions with predicates' do
        context '.to_conjunctive_normal_form' do
          it do
            a = RuleRover::Statements::Predicate.new(identifier: "A", assignments: { "x" => nil })
            b = RuleRover::Statements::Predicate.new(identifier: "B", assignments: { "x" => nil })
            c = RuleRover::Statements::Predicate.new(identifier: "C", assignments: { "x" => nil })
            d = RuleRover::Statements::Predicate.new(identifier: "D", assignments: { "x" => nil })

            not_a_or_b_or_c_bicond_d = a.or(b).not.or(c.≡(d))
            # "(not(A or B) or (C ≡ D))"
            # (not(A) and not(B)) or ((C ⊃ D) and (D ⊃ C))
            # (not(A) and not(B)) or ((not(C) or D) and (not(D) or C))
            # "((not(A) and not(B)) or ((not(C) or D) and (not(D) or C)))"
            # (not(A) or ((not(C) or D) and (not(D) or C))) and (not(B) or ((not(C) or D) and (not(D) or C)))
            # (not(A) or (not(C) or D)) and (not(A) or (not(D) or C)) and (not(B) or (not(C) or D)) and (not(B) or (not(D) or C))

            result = RuleRover::Statements.to_conjunctive_normal_form(not_a_or_b_or_c_bicond_d)

            expect(result.to_s).to eq("(((not(A(x)) or (not(C(x)) or D(x))) and (not(A(x)) or (not(D(x)) or C(x)))) and ((not(B(x)) or (not(C(x)) or D(x))) and (not(B(x)) or (not(D(x)) or C(x)))))")
          end
        end
      end
    end
  end

  #####################################
  ### OG Statements Data Structures ###
  #####################################

  context 'complex statements' do
    context 'when conjunction or disjunction operator' do
      it 'return correct value' do
        as1 = RuleRover::Statements::AtomicStatement.new(true, :as1)
        as2 = RuleRover::Statements::AtomicStatement.new(false, :as2)
        cs1 = RuleRover::Statements::ComplexStatement.new(as1, as2, "or")

        expect(cs1.value).to be true
      end
    end
    context 'when conditional or biconditional operator' do
      it 'return correct value' do
        as1 = RuleRover::Statements::AtomicStatement.new(true, :as1)
        as2 = RuleRover::Statements::AtomicStatement.new(false, :as2)
        cs1 = RuleRover::Statements::ComplexStatement.new(as1, as2, "⊃")
        expect(cs1.value).to be false
      end
    end
    context 'when negation' do
      it 'return correct value' do
        as1 = RuleRover::Statements::AtomicStatement.new(false, :as1)
        cs1 = RuleRover::Statements::ComplexStatement.new(as1, nil, "not")
        expect(cs1.value).to be true
      end
    end
    describe '#clause?' do
      context 'complex statement composed with two atomic statements' do
        context 'when statement is a clause' do
          it 'returns true' do
            as1 = RuleRover::Statements::AtomicStatement.new(true, :as1)
            as2 = RuleRover::Statements::AtomicStatement.new(false, :as2)
            cs1 = RuleRover::Statements::ComplexStatement.new(as1, as2, "or")
            expect(cs1.clause?).to be true
          end
        end
        context 'when statement is not a clause' do
          it 'returns false' do
            as1 = RuleRover::Statements::AtomicStatement.new(true, :as1)
            as2 = RuleRover::Statements::AtomicStatement.new(false, :as2)
            cs1 = RuleRover::Statements::ComplexStatement.new(as1, as2, "and")
            expect(cs1.clause?).to be false
          end
        end
      end
      context 'complex statement composed with of other complex statements' do
        context 'when statement is a clause' do
          it 'returns true' do
            as1 = RuleRover::Statements::AtomicStatement.new(true, :as1)
            as2 = RuleRover::Statements::AtomicStatement.new(false, :as2)
            cs1 = RuleRover::Statements::ComplexStatement.new(as1, as2, "or")
            cs2 = RuleRover::Statements::ComplexStatement.new(as1, cs1, "or")

            expect(cs2.clause?).to be true
          end
        end
        context 'when statement is not a clause' do
          it 'returns false' do
            as1 = RuleRover::Statements::AtomicStatement.new(true, :as1)
            as2 = RuleRover::Statements::AtomicStatement.new(false, :as2)
            cs1 = RuleRover::Statements::ComplexStatement.new(as1, as2, "and")
            cs2 = RuleRover::Statements::ComplexStatement.new(as1, cs1, "or")

            expect(cs2.clause?).to be false
          end
        end
      end
    end
  end
  describe '#to_s' do
    context 'atomic statements' do
      it do
        as1 = RuleRover::Statements::AtomicStatement.new(true, :as1)
        expect(as1.to_s).to eq "as1: true"
      end
    end
    context 'complex statements' do
      it do
        as1 = RuleRover::Statements::AtomicStatement.new(true, :as1)
        as2 = RuleRover::Statements::AtomicStatement.new(true, :as2)
        as3 = RuleRover::Statements::AtomicStatement.new(true, :as3)
        as4 = RuleRover::Statements::AtomicStatement.new(true, :as4)

        cs1 = RuleRover::Statements::ComplexStatement.new(as1, as2, 'and')
        cs2 = RuleRover::Statements::ComplexStatement.new(as3, as4, 'and')
        cs3 = RuleRover::Statements::ComplexStatement.new(cs1, cs2, '⊃')

        expect(cs3.to_s).to eq "((as1 and as2) ⊃ (as3 and as4))"
      end
    end
  end
end
