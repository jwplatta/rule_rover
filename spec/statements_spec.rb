require 'spec_helper'

describe MyKen::Statements do
  describe 'Statement class' do
    context 'atomic statements' do
      it do
        aggregate_failures do
          expect(MyKen::Statements::Statement.new("A").to_s).to eq "A"
          expect do
            MyKen::Statements::Statement.new("and")
          end.to raise_error(ArgumentError)
        end
      end
    end
    context 'complex statements' do
      it do
        aggregate_failures do
          a = MyKen::Statements::Statement.new("A")
          b = MyKen::Statements::Statement.new("B")
          c = MyKen::Statements::Statement.new("C")
          d = MyKen::Statements::Statement.new("D")

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
    describe 'conjunctive normal form' do
      context 'complex statements' do
        context '.to_conjunctive_normal_form' do
          it do
            a = MyKen::Statements::Statement.new("A")
            b = MyKen::Statements::Statement.new("B")
            c = MyKen::Statements::Statement.new("C")
            d = MyKen::Statements::Statement.new("D")

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
            a = MyKen::Statements::Statement.new("A")
            b = MyKen::Statements::Statement.new("B")
            c = MyKen::Statements::Statement.new("C")
            b_bicond_c = b.≡(c)
            a_bicond_b = a.≡(b_bicond_c)
            result = MyKen::Statements.eliminate_biconditionals(a_bicond_b)
            expect(result.to_s).to eq("((A ⊃ ((B ⊃ C) and (C ⊃ B))) and (((B ⊃ C) and (C ⊃ B)) ⊃ A))")
          end
        end
        context '.eliminates_conditionals' do
          it do
            a = MyKen::Statements::Statement.new("A")
            b = MyKen::Statements::Statement.new("B")
            c = MyKen::Statements::Statement.new("C")
            b_cond_c = b.⊃(c)
            a_cond_b = a.⊃(b_cond_c)

            result = MyKen::Statements.eliminate_conditionals(a_cond_b)
            expect(result.to_s).to eq("(not(A) or (not(B) or C))")
          end
        end
        context '.move_negation_to_literals' do
          it 'eliminates double negation of atomic' do
            not_not_a = MyKen::Statements::Statement.new("A").not.not
            result = MyKen::Statements.move_negation_to_literals(not_not_a)
            expect(result.to_s).to eq "A"
          end
          it 'eliminates double negation of complex statement' do
            a = MyKen::Statements::Statement.new("A")
            b = MyKen::Statements::Statement.new("B")
            not_not_a_and_b = a.and(b).not.not
            result = MyKen::Statements.move_negation_to_literals(not_not_a_and_b)
            expect(result.to_s).to eq "(A and B)"
          end
          it do
            b = MyKen::Statements::Statement.new("B")
            c = MyKen::Statements::Statement.new("C")
            b_or_c = b.or(c)
            not_b_or_c = b_or_c.not
            result = MyKen::Statements.move_negation_to_literals(not_b_or_c)
            expect(result.to_s).to eq("(not(B) and not(C))")
          end
          it do
            a = MyKen::Statements::Statement.new("A")
            not_a = a.not
            b = MyKen::Statements::Statement.new("B")
            c = MyKen::Statements::Statement.new("C")
            b_or_c = b.or(c)
            not_b_or_c = b_or_c.not
            not_not_b_or_c_and_not_a = not_b_or_c.and(not_a).not
            result = MyKen::Statements.move_negation_to_literals(not_not_b_or_c_and_not_a)
            expect(result.to_s).to eq("((B or C) or A)")
          end
          it do
            a = MyKen::Statements::Statement.new("A")
            not_a = a.not
            b = MyKen::Statements::Statement.new("B")
            c = MyKen::Statements::Statement.new("C")
            b_or_c = b.or(c)
            not_b_or_c_and_not_a = b_or_c.and(not_a).not
            result = MyKen::Statements.move_negation_to_literals(not_b_or_c_and_not_a)
            expect(result.to_s).to eq("((not(B) and not(C)) or A)")
          end
        end
        context '.distribute' do
          it do
            a = MyKen::Statements::Statement.new("A")
            b = MyKen::Statements::Statement.new("B")
            c = MyKen::Statements::Statement.new("C")
            a_or_b_and_c = a.or(b.and(c))
            result = MyKen::Statements.distribute(a_or_b_and_c)
            expect(result.to_s).to eq("((A or B) and (A or C))")
          end
          it do
            a = MyKen::Statements::Statement.new("A")
            b = MyKen::Statements::Statement.new("B")
            c = MyKen::Statements::Statement.new("C")
            d = MyKen::Statements::Statement.new("D")
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

  #####################################
  ### OG Statements Data Structures ###
  #####################################

  context 'complex statements' do
    context 'when conjunction or disjunction operator' do
      it 'return correct value' do
        as1 = MyKen::Statements::AtomicStatement.new(true, :as1)
        as2 = MyKen::Statements::AtomicStatement.new(false, :as2)
        cs1 = MyKen::Statements::ComplexStatement.new(as1, as2, "or")

        expect(cs1.value).to be true
      end
    end
    context 'when conditional or biconditional operator' do
      it 'return correct value' do
        as1 = MyKen::Statements::AtomicStatement.new(true, :as1)
        as2 = MyKen::Statements::AtomicStatement.new(false, :as2)
        cs1 = MyKen::Statements::ComplexStatement.new(as1, as2, "⊃")
        expect(cs1.value).to be false
      end
    end
    context 'when negation' do
      it 'return correct value' do
        as1 = MyKen::Statements::AtomicStatement.new(false, :as1)
        cs1 = MyKen::Statements::ComplexStatement.new(as1, nil, "not")
        expect(cs1.value).to be true
      end
    end
    describe '#clause?' do
      context 'complex statement composed with two atomic statements' do
        context 'when statement is a clause' do
          it 'returns true' do
            as1 = MyKen::Statements::AtomicStatement.new(true, :as1)
            as2 = MyKen::Statements::AtomicStatement.new(false, :as2)
            cs1 = MyKen::Statements::ComplexStatement.new(as1, as2, "or")
            expect(cs1.clause?).to be true
          end
        end
        context 'when statement is not a clause' do
          it 'returns false' do
            as1 = MyKen::Statements::AtomicStatement.new(true, :as1)
            as2 = MyKen::Statements::AtomicStatement.new(false, :as2)
            cs1 = MyKen::Statements::ComplexStatement.new(as1, as2, "and")
            expect(cs1.clause?).to be false
          end
        end
      end
      context 'complex statement composed with of other complex statements' do
        context 'when statement is a clause' do
          it 'returns true' do
            as1 = MyKen::Statements::AtomicStatement.new(true, :as1)
            as2 = MyKen::Statements::AtomicStatement.new(false, :as2)
            cs1 = MyKen::Statements::ComplexStatement.new(as1, as2, "or")
            cs2 = MyKen::Statements::ComplexStatement.new(as1, cs1, "or")

            expect(cs2.clause?).to be true
          end
        end
        context 'when statement is not a clause' do
          it 'returns false' do
            as1 = MyKen::Statements::AtomicStatement.new(true, :as1)
            as2 = MyKen::Statements::AtomicStatement.new(false, :as2)
            cs1 = MyKen::Statements::ComplexStatement.new(as1, as2, "and")
            cs2 = MyKen::Statements::ComplexStatement.new(as1, cs1, "or")

            expect(cs2.clause?).to be false
          end
        end
      end
    end
  end
  describe '#to_s' do
    context 'atomic statements' do
      it do
        as1 = MyKen::Statements::AtomicStatement.new(true, :as1)
        expect(as1.to_s).to eq "as1: true"
      end
    end
    context 'complex statements' do
      it do
        as1 = MyKen::Statements::AtomicStatement.new(true, :as1)
        as2 = MyKen::Statements::AtomicStatement.new(true, :as2)
        as3 = MyKen::Statements::AtomicStatement.new(true, :as3)
        as4 = MyKen::Statements::AtomicStatement.new(true, :as4)

        cs1 = MyKen::Statements::ComplexStatement.new(as1, as2, 'and')
        cs2 = MyKen::Statements::ComplexStatement.new(as3, as4, 'and')
        cs3 = MyKen::Statements::ComplexStatement.new(cs1, cs2, '⊃')

        expect(cs3.to_s).to eq "((as1 and as2) ⊃ (as3 and as4))"
      end
    end
  end
end
