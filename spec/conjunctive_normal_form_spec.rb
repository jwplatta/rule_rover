require 'spec_helper'

describe MyKen::ConjunctiveNormalForm::Converter do
  let(:as1) { MyKen::Statements::AtomicStatement.new(true, :as1) }
  let(:as2) { MyKen::Statements::AtomicStatement.new(true, :as2) }
  let(:as3) { MyKen::Statements::AtomicStatement.new(true, :as3) }
  let(:as4) { MyKen::Statements::AtomicStatement.new(true, :as4) }
  let(:cnf_stmt1) { MyKen::Statements::ComplexStatement.new(as1, as2, "or") }
  let(:cnf_stmt2) { MyKen::Statements::ComplexStatement.new(as1, cnf_stmt1, "or") }
  let(:cnf_stmt3) { MyKen::Statements::ComplexStatement.new(as1, as2, "and") }
  let(:conditional_stmt1) { MyKen::Statements::ComplexStatement.new(as1, as2, "⊃") }
  let(:conditional_stmt2) { MyKen::Statements::ComplexStatement.new(as3, conditional_stmt1, "⊃") }
  let(:biconditional_stmt1) { MyKen::Statements::ComplexStatement.new(as1, as2, "≡") }
  let(:biconditional_stmt2) { MyKen::Statements::ComplexStatement.new(as3, as4, "≡") }

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

  describe '.eliminate_biconditionals' do
    context 'when statement is biconditional' do
      it 'transforms statement into a conjunction of conditionals' do
        cond1 = MyKen::Statements::ComplexStatement.new(as1, as2, "⊃")
        cond2 = MyKen::Statements::ComplexStatement.new(as2, as1, "⊃")
        expected_statement = MyKen::Statements::ComplexStatement.new(cond1, cond2, "and")
        expect(described_class.eliminate_biconditionals(biconditional_stmt1)).to eq(expected_statement)
      end
    end

    context 'when statement is many biconditionals' do
      it 'transforms statement into a conjunction of conditionals' do
        biconditional_stmts = MyKen::Statements::ComplexStatement.new(biconditional_stmt1, biconditional_stmt2, "and")

        cond1 = MyKen::Statements::ComplexStatement.new(as1, as2, "⊃")
        cond2 = MyKen::Statements::ComplexStatement.new(as2, as1, "⊃")
        eliminate_bicond1 = MyKen::Statements::ComplexStatement.new(cond1, cond2, "and")

        cond3 = MyKen::Statements::ComplexStatement.new(as3, as4, "⊃")
        cond4 = MyKen::Statements::ComplexStatement.new(as4, as3, "⊃")
        eliminate_bicond2 = MyKen::Statements::ComplexStatement.new(cond3, cond4, "and")

        expected_statement = MyKen::Statements::ComplexStatement.new(eliminate_bicond1, eliminate_bicond2, "and")

        expect(described_class.eliminate_biconditionals(biconditional_stmts)).to eq(expected_statement)
      end
    end

    context 'when statement is a nested biconditional' do
      it 'transforms statement into a conjunction of conditionals' do
        nested_bicond = MyKen::Statements::ComplexStatement.new(as1, biconditional_stmt1, "or")

        cond1 = MyKen::Statements::ComplexStatement.new(as1, as2, "⊃")
        cond2 = MyKen::Statements::ComplexStatement.new(as2, as1, "⊃")
        eliminate_bicond1 = MyKen::Statements::ComplexStatement.new(cond1, cond2, "and")

        expected_statement = MyKen::Statements::ComplexStatement.new(as1, eliminate_bicond1, "or")

        expect(described_class.eliminate_biconditionals(nested_bicond)).to eq(expected_statement)
      end
    end

    context 'when statement is not biconditional' do
      it 'returns the statement' do
        expect(described_class.eliminate_biconditionals(conditional_stmt1)).to eq(conditional_stmt1)
      end
    end
  end

  describe '.eliminate_conditionals' do
    context 'when statement is a single conditional' do
      it 'transforms statement into a disjunction with the first disjunct negated' do
        not_as1 = MyKen::Statements::ComplexStatement.new(as1, nil, "not")
        expected_statement = MyKen::Statements::ComplexStatement.new(not_as1, as2, "or")
        expect(described_class.eliminate_conditionals(conditional_stmt1)).to eq(expected_statement)
      end
    end

    context 'when statement has many conditionals' do
      it 'transforms all conditionals' do
        cond1 = MyKen::Statements::ComplexStatement.new(as1, as2, "⊃")
        cond2 = MyKen::Statements::ComplexStatement.new(as3, as4, "⊃")
        cond3 = MyKen::Statements::ComplexStatement.new(as1, as4, "⊃")
        cond1_and_cond2 = MyKen::Statements::ComplexStatement.new(cond1, cond2, "and")
        cond1_and_cond2_or_cond3 = MyKen::Statements::ComplexStatement.new(cond1_and_cond2, cond3, "or")

        # ((as1 ⊃ as2) and (as3 ⊃ as4) or (as1 ⊃ as4))
        # ((not(as1) or as2) and (not(as3) or as4) or (not(as1) or as4))
        not_as1 = MyKen::Statements::ComplexStatement.new(as1, nil, "not")
        not_as3 = MyKen::Statements::ComplexStatement.new(as3, nil, "not")
        not_as1_or_as2 = MyKen::Statements::ComplexStatement.new(not_as1, as2, "or")
        not_as3_or_as4 = MyKen::Statements::ComplexStatement.new(not_as3, as4, "or")
        not_as1_or_as4 = MyKen::Statements::ComplexStatement.new(not_as1, as4, "or")
        not_as1_or_as2_and_not_as3_or_as4 = MyKen::Statements::ComplexStatement.new(not_as1_or_as2, not_as3_or_as4,"and")
        expected_statement = MyKen::Statements::ComplexStatement.new(not_as1_or_as2_and_not_as3_or_as4, not_as1_or_as4, "or")

        expect(described_class.eliminate_conditionals(cond1_and_cond2_or_cond3)).to eq(expected_statement)
      end
    end

    context 'when statement is not conditinoal' do
      it 'returns the statement' do
        expect(described_class.eliminate_conditionals(cnf_stmt1)).to eq(cnf_stmt1)
      end
    end
  end

  describe 'negation statements' do
    describe '.eliminate_double_negation' do
      context 'when atomic statement is double negated' do
        it 'eliminates the double negation' do
          not_as1 = MyKen::Statements::ComplexStatement.new(as1, nil, "not")
          double_negation_stmt = MyKen::Statements::ComplexStatement.new(not_as1, nil, "not")
          expect(described_class.eliminate_double_negation(double_negation_stmt)).to eq(as1)
        end
      end
      context 'when multiple atomic statements are double negated' do
        it 'eliminates the double negation' do
          not_as1 = MyKen::Statements::ComplexStatement.new(as1, nil, "not")
          dbl_neg_as1 = MyKen::Statements::ComplexStatement.new(not_as1, nil, "not")

          not_as2 = MyKen::Statements::ComplexStatement.new(as2, nil, "not")
          dbl_neg_as2 = MyKen::Statements::ComplexStatement.new(not_as2, nil, "not")

          conj_dbl_neg = MyKen::Statements::ComplexStatement.new(dbl_neg_as1, dbl_neg_as2, "and")

          expected_statement = MyKen::Statements::ComplexStatement.new(as1, as2, "and")

          expect(described_class.eliminate_double_negation(conj_dbl_neg)).to eq(expected_statement)
        end
      end
      context 'when atomic statement is not doulbe negated' do
        it 'returns the statement' do
          not_as1 = MyKen::Statements::ComplexStatement.new(as1, nil, "not")
          expect(described_class.eliminate_double_negation(not_as1)).to eq(not_as1)
        end
      end
    end
    describe '.move_negation_to_literals' do
      context 'negation of a disjunction' do
        it "applies DeMorgan's law" do
          not_cnf_stmt1 = MyKen::Statements::ComplexStatement.new(cnf_stmt1, nil, "not")
          not_as1 = MyKen::Statements::ComplexStatement.new(as1, nil, "not")
          not_as2 = MyKen::Statements::ComplexStatement.new(as2, nil, "not")
          expected_statement = MyKen::Statements::ComplexStatement.new(not_as1, not_as2, "and")

          expect(described_class.move_negation_to_literals(not_cnf_stmt1)).to eq(expected_statement)
        end
      end
      context 'negation of a conjunction' do
        it "applies DeMorgan's law" do
          not_cnf_stmt3 = MyKen::Statements::ComplexStatement.new(cnf_stmt3, nil, "not")
          not_as1 = MyKen::Statements::ComplexStatement.new(as1, nil, "not")
          not_as2 = MyKen::Statements::ComplexStatement.new(as2, nil, "not")
          expected_statement = MyKen::Statements::ComplexStatement.new(not_as1, not_as2, "or")

          expect(described_class.move_negation_to_literals(not_cnf_stmt3)).to eq(expected_statement)
        end
      end
      context 'multiple negations of a disjunction' do
        it "applies DeMorgan's law" do
          disj1 = MyKen::Statements::ComplexStatement.new(as1, as2, "or")
          not_disj1 = MyKen::Statements::ComplexStatement.new(disj1, nil, "not")
          disj2 = MyKen::Statements::ComplexStatement.new(as2, as1, "or")
          not_disj2 = MyKen::Statements::ComplexStatement.new(disj2, nil, "not")
          not_disj1_and_not_disj2 = MyKen::Statements::ComplexStatement.new(not_disj1, not_disj2, "and")

          # not(as1 or as2) and not(as2 or as1)
          # (not(as1) and not(as2)) and (not(as2) and not(as1))
          not_as1 = MyKen::Statements::ComplexStatement.new(as1, nil, "not")
          not_as2 = MyKen::Statements::ComplexStatement.new(as2, nil, "not")
          conj1 = MyKen::Statements::ComplexStatement.new(not_as1, not_as2, "and")
          conj2 = MyKen::Statements::ComplexStatement.new(not_as2, not_as1, "and")
          expected_statement = MyKen::Statements::ComplexStatement.new(conj1, conj2, "and")

          expect(described_class.move_negation_to_literals(not_disj1_and_not_disj2)).to eq(expected_statement)
        end
      end
    end
  end

  describe '.distribute' do
    context 'atomic statement' do
      it 'returns the statement' do
        expect(described_class.distribute_twice(as1)).to eq as1
      end
    end

    context 'disjunction of atomic statements' do
      it 'returns the statement' do
        expect(described_class.distribute_twice(cnf_stmt1)).to eq cnf_stmt1
      end
    end

    context 'conjunction of atomic statements' do
      it 'returns the statement' do
        expect(described_class.distribute_twice(cnf_stmt3)).to eq cnf_stmt3
      end
    end

    context 'disjunction of complex statements' do
      it 'distributes over the OR over the AND' do
        conj = MyKen::Statements::ComplexStatement.new(as1, as2, "and")
        disj = MyKen::Statements::ComplexStatement.new(as3, conj, "or")

        as3_or_as1 = MyKen::Statements::ComplexStatement.new(as3, as1, "or")
        as3_or_as2 = MyKen::Statements::ComplexStatement.new(as3, as2, "or")
        as3_or_as1_and_as3_or_as2 = MyKen::Statements::ComplexStatement.new(as3_or_as1, as3_or_as2, "and")

        # as3 or (as1 and as2)
        # (as3 or as1) and (as3 or as2)
        expect(described_class.distribute(disj)).to eq as3_or_as1_and_as3_or_as2
      end
    end

    context 'conjunction of complex statements' do
      it 'returns the statement' do
        disj = MyKen::Statements::ComplexStatement.new(as1, as2, "or")
        conj = MyKen::Statements::ComplexStatement.new(as3, disj, "and")
        expect(described_class.distribute_twice(conj)).to eq conj
      end
    end

    context 'statement is neither a conjunction nor a disjunction' do
      it 'returns the statement' do
        cond = MyKen::Statements::ComplexStatement.new(as1, as2, "⊃")
        expect(described_class.distribute_twice(cond)).to eq cond
      end
    end

    context 'statement contains nested distributions' do
      it 'distributes over the OR over the AND' do
        conj = MyKen::Statements::ComplexStatement.new(as3, as4, "and")
        nested_disj = MyKen::Statements::ComplexStatement.new(as2, conj, "or")
        outer_disj = MyKen::Statements::ComplexStatement.new(as1, nested_disj, "or")

        # as1 or (as2 or (as3 and as4))
        # as1 or ((as2 or as3) and (as2 or as4))
        # (as1 or (as2 or as3)) and (as1 or (as2 or as4))
        as2_or_as3 = MyKen::Statements::ComplexStatement.new(as2, as3, "or")
        as1_or_as2_or_as3 = MyKen::Statements::ComplexStatement.new(as1, as2_or_as3, "or")
        as2_or_as4 = MyKen::Statements::ComplexStatement.new(as2, as4, "or")
        as1_or_as2_or_as4 = MyKen::Statements::ComplexStatement.new(as1, as2_or_as4, "or")
        expected_statement = MyKen::Statements::ComplexStatement.new(as1_or_as2_or_as3, as1_or_as2_or_as4, "and")

        expect(described_class.distribute_twice(outer_disj)).to eq expected_statement
      end
    end
  end
  context 'when statement is NOT in CNF' do
    context 'conditional statements' do
      context 'statement with two clauses' do
        it 'returns a statement in CNF' do
          not_as1 = MyKen::Statements::ComplexStatement.new(as1, nil, "not")
          expected_statement = MyKen::Statements::ComplexStatement.new(not_as1, as2, "or")

          expect(described_class.run(conditional_stmt1)).to eq(expected_statement)
        end
      end
      context 'statement with three clauses' do
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
      context 'negation of a biconditional' do
        it 'returns a statement in CNF' do
          not_biconditional = MyKen::Statements::ComplexStatement.new(biconditional_stmt1, nil, "not")
          not_as1 = MyKen::Statements::ComplexStatement.new(as1, nil, "not")
          not_as2 = MyKen::Statements::ComplexStatement.new(as2, nil, "not")
          # NOTE:
          # not(as1 ≡ as2)
          # -> not((as1 ⊃ as2) and (as2 ⊃ as1))
          # -> not((not(as1) or as2) and (not(as2) or as1))
          # -> not(not(as1) or as2) or not(not(as2) or as1)
          # -> (not(not(as1)) and not(as2)) or (not(not(as2)) and not(as1))
          # -> (as1 and not(as2)) or (as2 and not(as1))
          # -> (as1 or (as2 and not(as1)) and (not(as2) or (as2 and not(as1))
          # -> (as1 or as2) and (as1 or not(as1)) and (not(as2) or as2) and (not(as2) or not(as1))
          # (((as1 or as2) and (as1 or not(as1))) and ((not(as2) or as2) and (not(as2) or not(as1))))

          as1_or_as2 = MyKen::Statements::ComplexStatement.new(as1, as2, "or")
          as1_or_not_as1 = MyKen::Statements::ComplexStatement.new(as1, not_as1, "or")
          as1_or_as2_and_as1_or_not_as1 = MyKen::Statements::ComplexStatement.new(as1_or_as2, as1_or_not_as1, "and")

          not_as2_or_as2 = MyKen::Statements::ComplexStatement.new(not_as2, as2, "or")
          not_as2_or_not_as1 = MyKen::Statements::ComplexStatement.new(not_as2, not_as1, "or")
          not_as2_or_as2_and_not_as2_or_not_as1 = MyKen::Statements::ComplexStatement.new(not_as2_or_as2, not_as2_or_not_as1, "and")

          expected_statement = MyKen::Statements::ComplexStatement.new(as1_or_as2_and_as1_or_not_as1, not_as2_or_as2_and_not_as2_or_not_as1, "and")
          expect(described_class.run(not_biconditional)).to eq(expected_statement)
        end
      end
    end
    context 'complex statements' do
      context '' do
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
      context 'disjunction of conjunction and a disjunction' do
        it 'returns a statement in CNF' do
          as1 = MyKen::Statements::AtomicStatement.new(true, :as1)
          as2 = MyKen::Statements::AtomicStatement.new(false, :as2)
          as3 = MyKen::Statements::AtomicStatement.new(false, :as3)
          as1_and_as2 = MyKen::Statements::ComplexStatement.new(as1, as2, 'and')
          as1_or_as3 = MyKen::Statements::ComplexStatement.new(as1, as3, 'or')
          as1_and_as2_or_as1_or_as3 = MyKen::Statements::ComplexStatement.new(as1_and_as2, as1_or_as3, 'or')

          as1_or_as1_or_as3 = MyKen::Statements::ComplexStatement.new(as1, as1_or_as3, "or")
          as2_or_as1_or_as3 = MyKen::Statements::ComplexStatement.new(as2, as1_or_as3, "or")
          expected_statement = MyKen::Statements::ComplexStatement.new(as1_or_as1_or_as3, as2_or_as1_or_as3, "and")

          expect(described_class.run(as1_and_as2_or_as1_or_as3)).to eq(expected_statement)
        end
      end
    end
  end
end
