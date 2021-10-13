require 'spec_helper'

describe MyKen::Statements::ToCNF do
  describe '#initialize' do
    context 'when passed an instance of a proposition' do
      it 'does not raise' do
        prop = MyKen::Statements::Proposition.new("A")
        expect do
          described_class.new(prop)
        end.not_to raise_error
      end
    end
    context 'when not passed an instance of a proposition' do
      it 'raises' do
        expect do
          described_class.new("A")
        end.to raise_error(ArgumentError)
      end
    end
  end
  xdescribe 'elimination of biconditionals' do
    # NOTE: test fails because the final statement does not meet
    # the other conditions for conjunctive normal form
    it 'returns proposition with biconditionals replaced with conditionals' do
      a = MyKen::Statements::Proposition.new("A")
      b = MyKen::Statements::Proposition.new("B")
      c = MyKen::Statements::Proposition.new("C")
      b_bicond_c = b.≡(c)
      a_bicond_b = a.≡(b_bicond_c)
      result = described_class.transform(a_bicond_b)
      expect(result.to_s).to eq("((A ⊃ ((B ⊃ C) and (C ⊃ B))) and (((B ⊃ C) and (C ⊃ B)) ⊃ A))")
    end
  end
  describe 'elimination of conditionals' do
    it do
      prop = MyKen::Statements::Proposition.parse("(A ⊃ (B ⊃ C))")
      result = described_class.transform(prop)
      expect(result.to_s).to eq("((not(A) or not(B)) or C)")
    end
  end
  describe 'move negation operator to literals' do
    it 'eliminates double negation of atomic' do
      prop = MyKen::Statements::Proposition.parse("not(not(A))")
      result = described_class.transform(prop)
      expect(result.to_s).to eq "A"
    end
    it 'eliminates double negation of complex statement' do
      prop = MyKen::Statements::Proposition.parse("not(not(A and B))")
      result = described_class.transform(prop)
      expect(result.to_s).to eq "(A and B)"
    end
    it do
      prop = MyKen::Statements::Proposition.parse("not(B or C)")
      result = described_class.transform(prop)
      expect(result.to_s).to eq("(not(B) and not(C))")
    end
    it do
      prop = MyKen::Statements::Proposition.parse("not(not(B or C) and not(A))")
      result = described_class.transform(prop)
      expect(result.to_s).to eq("((A or B) or C)")
    end
    xit do
      # NOTE: test fails because the final statment is not distributed
      a = MyKen::Statements::Proposition.new("A")
      not_a = a.not
      b = MyKen::Statements::Proposition.new("B")
      c = MyKen::Statements::Proposition.new("C")
      b_or_c = b.or(c)
      not_b_or_c_and_not_a = b_or_c.and(not_a).not
      result = described_class.transform(not_b_or_c_and_not_a)
      expect(result.to_s).to eq("((not(B) and not(C)) or A)")
    end
  end
  describe 'distribution of OR over AND' do
    it do
      prop = MyKen::Statements::Proposition.parse("(A or (B and C))")
      result = described_class.transform(prop)
      expect(result.to_s).to eq("((A or B) and (A or C))")
    end
    it do
      prop = MyKen::Statements::Proposition.parse("((A and D) or (B and C))")
      result = described_class.transform(prop)
      # "((A and D) or (B and C))"
      # (A or (B and C)) and (D or (B and C))
      # (((A or B) and (A or C)) and ((D or B) and (D or C)))
      # "(((A or B) and (A or C)) and ((D or B) and (D or C)))"
      expect(result.to_s).to eq("(((A or B) and (A or C)) and ((B or D) and (C or D)))")
    end
  end
  describe '.transform' do
    it 'returns a new proposition in conjunctive normal form' do
      prop = MyKen::Statements::Proposition.parse("(not(A or B) or (C ≡ D))")
      # "(not(A or B) or (C ≡ D))"
      # (not(A) and not(B)) or ((C ⊃ D) and (D ⊃ C))
      # (not(A) and not(B)) or ((not(C) or D) and (not(D) or C))
      # "((not(A) and not(B)) or ((not(C) or D) and (not(D) or C)))"
      # (not(A) or ((not(C) or D) and (not(D) or C))) and (not(B) or ((not(C) or D) and (not(D) or C)))
      # (not(A) or (not(C) or D)) and (not(A) or (not(D) or C)) and (not(B) or (not(C) or D)) and (not(B) or (not(D) or C))
      result = described_class.transform(prop)
      expect(result).to be_a MyKen::Statements::Proposition
      expect(result.to_s).to eq(
        "((((not(A) or not(C)) or D) and ((not(A) or C) or not(D))) and (((not(B) or not(C)) or D) and ((not(B) or C) or not(D))))"
      )
    end
  end
  describe '#sort_disjuncts' do
    it do
      prop = MyKen::Statements::Proposition.parse("(E or D) and ((X or (B or A)) and (P or O))")
      cnf = described_class.new(prop)
      expect(cnf.sort_terms(prop).to_s).to eq "((D or E) and (((A or B) or X) and (O or P)))"
    end
  end
end