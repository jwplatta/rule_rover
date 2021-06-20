require 'spec_helper'

describe MyKen::ConjunctiveNormalForm::Converter do
  let(:as1) { MyKen::Statements::AtomicStatement.new(true, :as1) }
  let(:as2) { MyKen::Statements::AtomicStatement.new(true, :as2) }
  let(:as3) { MyKen::Statements::AtomicStatement.new(true, :as3) }
  let(:cnf_stmt1) { MyKen::Statements::ComplexStatement.new(as1, as2, "or") }
  let(:cnf_stmt2) { MyKen::Statements::ComplexStatement.new(as1, cnf_stmt1, "or") }
  let(:cnf_stmt3) { MyKen::Statements::ComplexStatement.new(as1, as2, "and") }
  let(:conditional_stmt1) { MyKen::Statements::ComplexStatement.new(as1, as2, "⊃") }
  let(:conditional_stmt2) { MyKen::Statements::ComplexStatement.new(as3, conditional_stmt1, "⊃") }
  let(:biconditional_stmt1) { MyKen::Statements::ComplexStatement.new(as1, as2, "≡") }

  it do
    expect do
      described_class.new
    end.to_not raise_error
  end

  context 'when statement is atomic' do
    it 'returns the atomic statement' do
      expect(described_class.run(as1)).to eq(as1)
    end
  end

  context 'when statement is in CNF' do
    context 'when statement has two clauses' do
      it 'returns the complex statement' do
        expect(described_class.run(cnf_stmt1)).to eq(cnf_stmt1)
      end
    end

    context 'when statement has three clauses' do
      it 'returns the complex statement' do
        expect(described_class.run(cnf_stmt2)).to eq(cnf_stmt2)
      end
    end
  end

  describe 'negation statements' do
    context 'double negation of an atomic statement' do
      it 'eliminates the double negation' do
        not_as1 = MyKen::Statements::ComplexStatement.new(as1, nil, "not")
        double_negation_stmt = MyKen::Statements::ComplexStatement.new(not_as1, nil, "not")
        expect(described_class.run(double_negation_stmt)).to eq(as1)
      end
    end
    context 'negation of a disjunction' do
      it "applies DeMorgan's law" do
        not_cnf_stmt1 = MyKen::Statements::ComplexStatement.new(cnf_stmt1, nil, "not")
        not_as1 = MyKen::Statements::ComplexStatement.new(as1, nil, "not")
        not_as2 = MyKen::Statements::ComplexStatement.new(as2, nil, "not")
        expected_statement = MyKen::Statements::ComplexStatement.new(not_as1, not_as2, "and")
        expect(described_class.run(not_cnf_stmt1)).to eq(expected_statement)
      end
    end
    context 'negation of a conjunction' do
      it "applies DeMorgan's law" do
        not_cnf_stmt3 = MyKen::Statements::ComplexStatement.new(cnf_stmt3, nil, "not")
        not_as1 = MyKen::Statements::ComplexStatement.new(as1, nil, "not")
        not_as2 = MyKen::Statements::ComplexStatement.new(as2, nil, "not")
        expected_statement = MyKen::Statements::ComplexStatement.new(not_as1, not_as2, "or")
        expect(described_class.run(not_cnf_stmt3)).to eq(expected_statement)
      end
    end
    context 'negation of a conditional' do
      it "applies DeMorgan's law" do
        not_conditional_stmt1 = MyKen::Statements::ComplexStatement.new(conditional_stmt1, nil, "not")
        not_as2 = MyKen::Statements::ComplexStatement.new(as2, nil, "not")
        expected_statement = MyKen::Statements::ComplexStatement.new(as1, not_as2, "and")
        # NOTE: not(as1 ⊃ as2) -> not(not(as1) or as2) -> as1 and not(as2)
        expect(described_class.run(not_conditional_stmt1)).to eq(expected_statement)
      end
    end
    context 'negation of a biconditional' do
      it "applies DeMorgan's law" do
        not_biconditional = MyKen::Statements::ComplexStatement.new(biconditional_stmt1, nil, "not")
        not_as1 = MyKen::Statements::ComplexStatement.new(as1, nil, "not")
        not_as2 = MyKen::Statements::ComplexStatement.new(as2, nil, "not")
        as1_and_not_as2 = MyKen::Statements::ComplexStatement.new(as1, not_as2, "and")
        as2_and_not_as1 = MyKen::Statements::ComplexStatement.new(as2, not_as1, "and")
        # NOTE:
        # not(as1 ≡ as2)
        # -> not((as1 ⊃ as2) and (as2 ⊃ as1))
        # -> not((not(as1) or as2) and (not(as2) or as1))
        # -> not(not(as1) or as2) or not(not(as2) or as1)
        # -> (not(not(as1)) and not(as2)) or (not(not(as2)) and not(as1))
        # -> (as1 and not(as2)) or (as2 and not(as1))
        expected_statement = MyKen::Statements::ComplexStatement.new(as1_and_not_as2, as2_and_not_as1, "or")
        expect(described_class.run(not_biconditional)).to eq(expected_statement)
      end
    end
  end
  context 'when statement is NOT in CNF' do
    context 'conditional statements' do
      context 'when statement has two clauses' do
        it 'returns a statement in CNF' do
          not_as1 = MyKen::Statements::ComplexStatement.new(as1, nil, "not")
          expected_statement = MyKen::Statements::ComplexStatement.new(not_as1, as2, "or")
          expect(described_class.run(conditional_stmt1)).to eq(expected_statement)
        end
      end
      context 'when statement has three clauses' do
        it 'returns a statement in CNF' do
          not_as1 = MyKen::Statements::ComplexStatement.new(as1, nil, "not")
          not_as3 = MyKen::Statements::ComplexStatement.new(as3, nil, "not")
          conditional_stmt1_in_CNF = MyKen::Statements::ComplexStatement.new(not_as1, as2, "or")
          expected_statement = MyKen::Statements::ComplexStatement.new(not_as3, conditional_stmt1_in_CNF, "or")

          # NOTE: not(as3) or not(as1) or as2
          expect(described_class.run(conditional_stmt2)).to eq(expected_statement)
        end
      end
    end
    context 'biconditional statements' do
      context 'biconditional statement composed with two atomic statements' do
        it 'returns a statement in CNF' do
          not_as1 = MyKen::Statements::ComplexStatement.new(as1, nil, "not")
          not_as2 = MyKen::Statements::ComplexStatement.new(as2, nil, "not")
          first_condition_in_CNF = MyKen::Statements::ComplexStatement.new(not_as1, as2, "or")
          second_condition_in_CNF = MyKen::Statements::ComplexStatement.new(not_as2, as1, "or")
          expected_statement = MyKen::Statements::ComplexStatement.new(first_condition_in_CNF, second_condition_in_CNF, "and")
          expect(described_class.run(biconditional_stmt1)).to eq(expected_statement)
        end
      end
    end
    context 'complex statement' do
      it 'returns a statement in CNF' do
        # NOTE: from book
        # as1 :: P1
        # as2 :: P2
        # as3 :: B

        # ((not(B) or (P1 or P2)) and ((not(P1) and not(P2)) or P3))
        # ((not(B) or (P1 or P2)) and (not(P1) or P3) and (not(P2) or P3))
        # ((not(as3) or (as1 or as2)) and ((not(as1) and not(as2)) or as3))
        # ((not(as3) or (as1 or as2)) and ((not(as1) or as3) and (not(as2) or as3)))

        disj_stmt = MyKen::Statements::ComplexStatement.new(as1, as2, "or")
        complex_stmt = MyKen::Statements::ComplexStatement.new(as3, disj_stmt, "≡")

        as1_or_as2 = MyKen::Statements::ComplexStatement.new(as1, as2, "or")
        not_as3 = MyKen::Statements::ComplexStatement.new(as3, nil, "not")
        not_as3_or_as1_or_as2 = MyKen::Statements::ComplexStatement.new(not_as3, as1_or_as2, "or")
        not_as1 = MyKen::Statements::ComplexStatement.new(as1, nil, "not")
        not_as1_or_as3 = MyKen::Statements::ComplexStatement.new(not_as1, as3, "or")
        not_as2 = MyKen::Statements::ComplexStatement.new(as2, nil, "not")
        not_as2_or_as3 = MyKen::Statements::ComplexStatement.new(not_as2, as3, "or")
        not_as1_or_as3_and_not_as2_or_as3 = MyKen::Statements::ComplexStatement.new(not_as1_or_as3, not_as2_or_as3, "and")
        expected_statement = MyKen::Statements::ComplexStatement.new(not_as3_or_as1_or_as2, not_as1_or_as3_and_not_as2_or_as3, "and")

        expect(described_class.run(complex_stmt)).to eq(expected_statement)
      end
    end
  end
end
