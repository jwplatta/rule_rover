require 'spec_helper'

describe MyKen::Statements::Proposition do
  describe '.parse' do
    it 'returns atomic proposition' do
      expect(described_class.parse("A")).to eq described_class.new("A")
    end
    it 'returns negation' do
      expect(described_class.parse("not(A)")).to eq described_class.new("not", "A")
    end
    it 'returns double negation' do
      expect(described_class.parse("not(not(A))").to_s).to eq "not(not(A))"
    end
    it do
      prop_sting = "((A or B) and ((E ≡ F) and not(C ⊃ B)))"
      result = described_class.parse(prop_sting)
      expect(result.to_s).to eq prop_sting
    end
    it do
      prop_sting = "((A or not(B)) and ((W ≡ W) and not(C ⊃ B)))"
      result = described_class.parse(prop_sting)
      expect(result.to_s).to eq prop_sting
    end
  end

  describe '#initialize' do
    context 'well formed formulas' do
      it 'inits an atomic proposition' do
        expect(MyKen::Statements::Proposition.new("A").symbol).to eq "A"
      end
      it 'inits negated atomic proposition' do
        prop = MyKen::Statements::Proposition.new("not", "A")
        expect(prop.operator).to eq "not"
        expect(prop.terms.map(&:symbol)).to eq ["A"]
      end
      it 'inits a complex proposition' do
        prop = MyKen::Statements::Proposition.new("and", "A", "B")
        expect(prop.terms.map(&:symbol)).to eq ["A", "B"]
        expect(prop.operator).to eq "and"
      end
    end
    context 'syntax errors' do
      it 'raises when passed an operator only' do
        expect do
          MyKen::Statements::Proposition.new("not")
        end.to raise_error(MyKen::Statements::NotWellFormedFormula)
      end
      it 'raises when passed connective and one literal' do
        expect do
          MyKen::Statements::Proposition.new("and", "A")
        end.to raise_error(MyKen::Statements::NotWellFormedFormula)
      end
      it 'raises when statements contain operators' do
        expect do
          MyKen::Statements::Proposition.new("and", "A", "or", "B", "C")
        end.to raise_error(MyKen::Statements::NotWellFormedFormula)
      end
    end
  end
  describe '#to_s' do
    it 'returns correct string for atomic proposition' do
      expect(MyKen::Statements::Proposition.new("A").to_s).to eq "A"
    end
    it 'returns correct string for negated proposition' do
      expect(MyKen::Statements::Proposition.new("not", "A").to_s).to eq "not(A)"
    end
    it 'returns correct string for complex proposition' do
      aggregate_failures do
        expect(MyKen::Statements::Proposition.new("and", "A", "B").to_s).to eq "(A and B)"
        expect(MyKen::Statements::Proposition.new("or", "A", "B").to_s).to eq "(A or B)"
        expect(MyKen::Statements::Proposition.new("⊃", "A", "B").to_s).to eq "(A ⊃ B)"
        expect(MyKen::Statements::Proposition.new("≡", "A", "B").to_s).to eq "(A ≡ B)"
      end
    end
    it 'returns correct string really complex proposition' do
      term = MyKen::Statements::Proposition.new("and", "A", "B")
      prop = MyKen::Statements::Proposition.new("or", "C", term)
      expect(prop.to_s).to eq "(C or (A and B))"
    end
  end
  describe 'to_conjuncts' do
    it 'returns an array of conjuncts' do
      prop = described_class.parse("A and (B and C)")
      expect(prop.to_conjuncts.map(&:to_s)).to eq ["A", "B", "C"]
    end
    it 'returns an array of conjuncts' do
      prop = described_class.parse("(A or E) and (B and (C or D))")
      expect(prop.to_conjuncts.map(&:to_s)).to eq ["(A or E)", "B", "(C or D)"]
    end
  end
  describe 'to_disjuncts' do
    it 'returns an array of disjuncts' do
      prop = described_class.parse("A or (B or C)")
      expect(prop.to_disjuncts.map(&:to_s)).to eq ["A", "B", "C"]
    end
  end
  describe 'proposition equality' do
    context 'when proposition are equal' do
      it 'returns true when atomic props are the same symbol' do
        prop_A = MyKen::Statements::Proposition.new("A")
        prop_B = MyKen::Statements::Proposition.new("A")
        expect(prop_A).to eq(prop_B)
      end
      it 'returns true when complex props are the same' do
        prop_A = MyKen::Statements::Proposition.new("and", "A", "B")
        prop_B = MyKen::Statements::Proposition.new("and", "A", "B")
        expect(prop_A).to eq(prop_B)
      end
      it 'returns true regardless of atomic proposition ordering' do
        expect(described_class.parse("A or B")).to eq described_class.parse("B or A")
      end
      it 'returns true for very long statements' do
        expect(
          described_class.parse("(((E or D) or A) and (L or (P or M)))")
        ).to eq described_class.parse("((L or (M or P)) and (A or (E or D)))")
      end
    end
    context 'when propositions are not equal' do
      it 'returns false when atomic props are the same symbol' do
        prop_A = MyKen::Statements::Proposition.new("A")
        prop_B = MyKen::Statements::Proposition.new("B")
        expect(prop_A).not_to eq(prop_B)
      end
    end
  end

  xdescribe '.definite_clause?' do
    context 'propositional statements' do
      it do
        a = MyKen::Statements::Proposition.new("A")
        b = MyKen::Statements::Proposition.new("B")
        c = MyKen::Statements::Proposition.new("C")
        clause = a.not.or(b.not).or(c)
        expect(MyKen::Statements.definite_clause?(clause)).to be true
      end
      it do
        a = MyKen::Statements::Proposition.new("A")
        b = MyKen::Statements::Proposition.new("B")
        clause = a.⊃(b)
        expect(MyKen::Statements.definite_clause?(clause)).to be true
      end
      it do
        a = MyKen::Statements::Proposition.new("A")
        b = MyKen::Statements::Proposition.new("B")
        c = MyKen::Statements::Proposition.new("C")
        clause = a.or(b).or(c)
        expect(MyKen::Statements.definite_clause?(clause)).to be false
      end
    end
  end
  xdescribe '.unify' do
    context 'variables and constants' do
      it do
        var_x = "x"
        var_y = "y"
        assignment = { "x" => "Harold" }
        result = MyKen::Statements.unify(var_x, var_y, assignment)
        expect(result).to eq({ "x" => "Harold", "y" => "Harold" })
      end
      it do
        var_x = "x"
        var_y = "y"
        assignments = { "z" => "Harold" }
        result = MyKen::Statements.unify(var_x, var_y, assignments)
        expect(result).to eq({ "x" => "y", "z" => "Harold" })
      end
      it do
        var_x = "x"
        const_y = "Y"
        result = MyKen::Statements.unify(var_x, const_y, {})
        expect(result).to eq({ "x" => "Y" })
      end
      it do
        const_x = "X"
        const_y = "Y"
        result = MyKen::Statements.unify(const_x, const_y, {})
        expect(result).to eq(nil)
      end
    end
    context 'statements' do
      it do
        predicate_x = MyKen::Statements::Predicate.new(identifier: "Protagonist", assignments: { "x" => "Batman" })
        predicate_y = MyKen::Statements::Predicate.new(identifier: "Antagonist", assignments: { "y" => "Joker" })
        predicate_z = MyKen::Statements::Predicate.new(identifier: "Protagonist", assignments: { "z" => nil })
        predicate_w = MyKen::Statements::Predicate.new(identifier: "Antagonist", assignments: { "w" => nil })

        result = MyKen::Statements.unify(predicate_x.and(predicate_y), predicate_z.and(predicate_w), {})
        expect(result).to eq({ "x" => "Batman", "y" => "Joker", "z" => "Batman", "w" => "Joker" })
      end
      it do
        predicate_x = MyKen::Statements::Predicate.new(identifier: "Protagonist", assignments: { "x" => "Batman" })
        predicate_y = MyKen::Statements::Predicate.new(identifier: "Antagonist", assignments: { "y" => "Joker" })
        predicate_z = MyKen::Statements::Predicate.new(identifier: "Protagonist", assignments: { "z" => nil })
        predicate_w = MyKen::Statements::Predicate.new(identifier: "Antagonist", assignments: { "w" => nil })
        result = MyKen::Statements.unify(predicate_x.and(predicate_y), predicate_w.and(predicate_z), {})
        expect(result).to eq({})
      end
      it do
        predicate_x = MyKen::Statements::Predicate.new(identifier: "Protagonist", assignments: { "x" => "Batman" })
        predicate_y = MyKen::Statements::Predicate.new(identifier: "Enemy", assignments: { "y" => "Joker" })
        predicate_z = MyKen::Statements::Predicate.new(identifier: "Enemy", assignments: { "z" => "Penguin" })
        predicate_a = MyKen::Statements::Predicate.new(identifier: "Protagonist", assignments: { "a" => nil })
        predicate_b = MyKen::Statements::Predicate.new(identifier: "Enemy", assignments: { "b" => nil })
        predicate_c = MyKen::Statements::Predicate.new(identifier: "Enemy", assignments: { "c" => nil })

        result = MyKen::Statements.unify(
          predicate_x.and(predicate_y).and(predicate_z),
          predicate_a.and(predicate_b).and(predicate_c),
          {}
        )

        expect(result).to eq({ "x" => "Batman", "y" => "Joker", "z" => "Penguin", "a" => "Batman", "b" => "Joker", "c" => "Penguin" })
      end
      it do
        predicate_x = MyKen::Statements::Predicate.new(identifier: "Protagonist", assignments: { "x" => "Batman" })
        predicate_y = MyKen::Statements::Predicate.new(identifier: "Antagonist", assignments: { "y" => nil })
        predicate_z = MyKen::Statements::Predicate.new(identifier: "Protagonist", assignments: { "z" => nil })
        predicate_w = MyKen::Statements::Predicate.new(identifier: "Antagonist", assignments: { "w" => "Joker" })

        result = MyKen::Statements.unify(predicate_x.and(predicate_y), predicate_z.and(predicate_w), {})
        expect(result).to eq({ "x" => "Batman", "y" => "Joker", "z" => "Batman", "w" => "Joker" })
      end
      it do
        predicate_x = MyKen::Statements::Predicate.new(identifier: "Protagonist", assignments: { "x" => "Batman" })
        predicate_y = MyKen::Statements::Predicate.new(identifier: "Antagonist", assignments: { "y" => "Penguin" })
        predicate_z = MyKen::Statements::Predicate.new(identifier: "Protagonist", assignments: { "z" => nil })
        predicate_w = MyKen::Statements::Predicate.new(identifier: "Antagonist", assignments: { "w" => "Joker" })

        result = MyKen::Statements.unify(predicate_x.and(predicate_y), predicate_z.and(predicate_w), {})
        expect(result).to eq({})
      end
      it do
        predicate_x = MyKen::Statements::Predicate.new(identifier: "Protagonist", assignments: { "x" => "Batman" })
        predicate_y = MyKen::Statements::Predicate.new(identifier: "Antagonist", assignments: { "y" => "Joker" })
        predicate_z = MyKen::Statements::Predicate.new(identifier: "Protagonist", assignments: { "z" => nil })
        predicate_w = MyKen::Statements::Predicate.new(identifier: "Antagonist", assignments: { "w" => nil })

        result = MyKen::Statements.unify(
          predicate_x.and(predicate_y),
          predicate_z.or(predicate_w),
          {}
        )
        expect(result).to eq({})
      end
    end
  end


  xdescribe 'statement equality' do
    it 'returns true for two atomics' do
      x = MyKen::Statements::Proposition.new("A")
      y = MyKen::Statements::Proposition.new("A")
      expect(x == y).to be true
    end
    it 'returns true for negation of two atomics' do
      x = MyKen::Statements::Proposition.new("A")
      y = MyKen::Statements::Proposition.new("A")
      expect(x.not == y.not).to be true
    end
    it 'returns true for negation of two atomics' do
      a = MyKen::Statements::Proposition.new("A")
      b = MyKen::Statements::Proposition.new("B")
      c = MyKen::Statements::Proposition.new("C")

      expect(a.or(b).or(c) == c.or(a).or(b)).to be true
    end
  end
  xdescribe 'Statement class' do
    describe '#==' do
      it 'returns true long sentence with conjuncts and disjuncts' do
        a = MyKen::Statements::Proposition.new("A")
        b = MyKen::Statements::Proposition.new("B")
        d = MyKen::Statements::Proposition.new("D")
        expect(a.or(b).and(b.or(d.not)) == d.not.or(b).and(b.or(a))).to be true
      end
      it 'returns true long sentence with conditionals and biconditionals' do
        a = MyKen::Statements::Proposition.new("A")
        b = MyKen::Statements::Proposition.new("B")
        c = MyKen::Statements::Proposition.new("C")
        d = MyKen::Statements::Proposition.new("D")

        expect(a.≡(b).and(c.⊃(d.or(a))) == b.≡(a).and(c.⊃(a.or(d)))).to be true
      end
      it 'returns true for two disjunctions in different order' do
        a = MyKen::Statements::Proposition.new("A")
        b = MyKen::Statements::Proposition.new("B")
        expect(a.or(b) == b.or(a)).to be true
      end
      it 'returns true for two conjunctions in different order' do
        a = MyKen::Statements::Proposition.new("A")
        b = MyKen::Statements::Proposition.new("B")
        expect(a.and(b) == b.and(a)).to be true
      end
      it 'returns true for two conjunctions in different order' do
        a = MyKen::Statements::Proposition.new("A")
        b = MyKen::Statements::Proposition.new("B")
        expect(a.and(b) == b.and(a)).to be true
      end
    end
    context 'complex statements' do
      it do
        aggregate_failures do
          a = MyKen::Statements::Proposition.new("A")
          b = MyKen::Statements::Proposition.new("B")
          c = MyKen::Statements::Proposition.new("C")
          d = MyKen::Statements::Proposition.new("D")

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
          a = MyKen::Statements::Proposition.new("A")
          b = MyKen::Statements::Proposition.new("B")
          c = MyKen::Statements::Proposition.new("C")
          a_and_b_and_c = a.and(b).and(c)

          result = MyKen::Statements.conjuncts(a_and_b_and_c)
          expect(result).to eq([a, b, c])
        end
        it do
          a = MyKen::Statements::Proposition.new("A")
          b = MyKen::Statements::Proposition.new("B")
          c = MyKen::Statements::Proposition.new("C")
          d = MyKen::Statements::Proposition.new("D")
          a_or_b_and_c_or_d = a.or(b).and(c.or(d))

          result = MyKen::Statements.conjuncts(a_or_b_and_c_or_d)
          expect(result.map(&:to_s)).to eq([a.or(b).to_s, c.or(d).to_s])
        end
        it do
          a = MyKen::Statements::Proposition.new("A")
          b = MyKen::Statements::Proposition.new("B")
          c = MyKen::Statements::Proposition.new("C")
          d = MyKen::Statements::Proposition.new("D")
          e = MyKen::Statements::Proposition.new("E")
          f = MyKen::Statements::Proposition.new("F")

          a_or_b_and_c_and_d_or_e_or_f = a.or(b).and(c.and(d).and(e.or(f)))
          result = MyKen::Statements.conjuncts(a_or_b_and_c_and_d_or_e_or_f)
          expect(result.map(&:to_s)).to eq([a.or(b).to_s, c.to_s, d.to_s, e.or(f).to_s])
        end
      end
    end
    describe '.disjuncts' do
      context 'propositions' do
        it do
          a = MyKen::Statements::Proposition.new("A")
          b = MyKen::Statements::Proposition.new("B")
          c = MyKen::Statements::Proposition.new("C")
          a_or_b_or_c = a.or(b).or(c)

          result = MyKen::Statements.disjuncts(a_or_b_or_c)
          expect(result.map(&:to_s)).to eq([a.to_s, b.to_s, c.to_s])
        end
        it do
          a = MyKen::Statements::Proposition.new("A")
          b = MyKen::Statements::Proposition.new("B")
          c = MyKen::Statements::Proposition.new("C")
          d = MyKen::Statements::Proposition.new("D")

          a_or_b_or_c_or_not_d = a.or(b).or(c.or(d.not))
          result = MyKen::Statements.disjuncts(a_or_b_or_c_or_not_d)
          expect(result.map(&:to_s)).to eq([a.to_s, b.to_s, c.to_s, d.not.to_s])
        end
      end
    end
    describe 'conjunctive normal form' do
      context 'complex propositions' do
        context '.to_conjunctive_normal_form' do
          it do
            a = MyKen::Statements::Proposition.new("A")
            b = MyKen::Statements::Proposition.new("B")
            c = MyKen::Statements::Proposition.new("C")
            d = MyKen::Statements::Proposition.new("D")

            not_a_or_b_or_c_bicond_d = a.or(b).not.or(c.≡(d))
            # "(not(A or B) or (C ≡ D))"
            # (not(A) and not(B)) or ((C ⊃ D) and (D ⊃ C))
            # (not(A) and not(B)) or ((not(C) or D) and (not(D) or C))
            # "((not(A) and not(B)) or ((not(C) or D) and (not(D) or C)))"
            # (not(A) or ((not(C) or D) and (not(D) or C))) and (not(B) or ((not(C) or D) and (not(D) or C)))
            # (not(A) or (not(C) or D)) and (not(A) or (not(D) or C)) and (not(B) or (not(C) or D)) and (not(B) or (not(D) or C))

            result = MyKen::Statements.to_conjunctive_normal_form(not_a_or_b_or_c_bicond_d)

            expect(result.to_s).to eq("(((not(A) or (not(C) or D)) and (not(A) or (not(D) or C))) and ((not(B) or (not(C) or D)) and (not(B) or (not(D) or C))))")
          end
        end
        context '.eliminates_biconditionals' do
          it do
            a = MyKen::Statements::Proposition.new("A")
            b = MyKen::Statements::Proposition.new("B")
            c = MyKen::Statements::Proposition.new("C")
            b_bicond_c = b.≡(c)
            a_bicond_b = a.≡(b_bicond_c)
            result = MyKen::Statements.eliminate_biconditionals(a_bicond_b)
            expect(result.to_s).to eq("((A ⊃ ((B ⊃ C) and (C ⊃ B))) and (((B ⊃ C) and (C ⊃ B)) ⊃ A))")
          end
        end
        context '.eliminates_conditionals' do
          it do
            a = MyKen::Statements::Proposition.new("A")
            b = MyKen::Statements::Proposition.new("B")
            c = MyKen::Statements::Proposition.new("C")
            b_cond_c = b.⊃(c)
            a_cond_b = a.⊃(b_cond_c)

            result = MyKen::Statements.eliminate_conditionals(a_cond_b)
            expect(result.to_s).to eq("(not(A) or (not(B) or C))")
          end
        end
        context '.move_negation_to_literals' do
          it 'eliminates double negation of atomic' do
            not_not_a = MyKen::Statements::Proposition.new("A").not.not
            result = MyKen::Statements.move_negation_to_literals(not_not_a)
            expect(result.to_s).to eq "A"
          end
          it 'eliminates double negation of complex statement' do
            a = MyKen::Statements::Proposition.new("A")
            b = MyKen::Statements::Proposition.new("B")
            not_not_a_and_b = a.and(b).not.not
            result = MyKen::Statements.move_negation_to_literals(not_not_a_and_b)
            expect(result.to_s).to eq "(A and B)"
          end
          it do
            b = MyKen::Statements::Proposition.new("B")
            c = MyKen::Statements::Proposition.new("C")
            b_or_c = b.or(c)
            not_b_or_c = b_or_c.not
            result = MyKen::Statements.move_negation_to_literals(not_b_or_c)
            expect(result.to_s).to eq("(not(B) and not(C))")
          end
          it do
            a = MyKen::Statements::Proposition.new("A")
            not_a = a.not
            b = MyKen::Statements::Proposition.new("B")
            c = MyKen::Statements::Proposition.new("C")
            b_or_c = b.or(c)
            not_b_or_c = b_or_c.not
            not_not_b_or_c_and_not_a = not_b_or_c.and(not_a).not
            result = MyKen::Statements.move_negation_to_literals(not_not_b_or_c_and_not_a)
            expect(result.to_s).to eq("((B or C) or A)")
          end
          it do
            a = MyKen::Statements::Proposition.new("A")
            not_a = a.not
            b = MyKen::Statements::Proposition.new("B")
            c = MyKen::Statements::Proposition.new("C")
            b_or_c = b.or(c)
            not_b_or_c_and_not_a = b_or_c.and(not_a).not
            result = MyKen::Statements.move_negation_to_literals(not_b_or_c_and_not_a)
            expect(result.to_s).to eq("((not(B) and not(C)) or A)")
          end
        end
        context '.distribute' do
          it do
            a = MyKen::Statements::Proposition.new("A")
            b = MyKen::Statements::Proposition.new("B")
            c = MyKen::Statements::Proposition.new("C")
            a_or_b_and_c = a.or(b.and(c))
            result = MyKen::Statements.distribute(a_or_b_and_c)
            expect(result.to_s).to eq("((A or B) and (A or C))")
          end
          it do
            a = MyKen::Statements::Proposition.new("A")
            b = MyKen::Statements::Proposition.new("B")
            c = MyKen::Statements::Proposition.new("C")
            d = MyKen::Statements::Proposition.new("D")
            a_and_d_or_b_and_c = a.and(d).or(b.and(c))
            result = MyKen::Statements.distribute(a_and_d_or_b_and_c)
            # "((A and D) or (B and C))"
            # (A or (B and C)) and (D or (B and C))
            # (((A or B) and (A or C)) and ((D or B) and (D or C)))
            # "(((A or B) and (A or C)) and ((D or B) and (D or C)))"
            expect(result.to_s).to eq("(((A or B) and (A or C)) and ((D or B) and (D or C)))")
          end
        end
      end
    end
  end
end
