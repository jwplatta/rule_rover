require 'spec_helper'

describe MyKen::StatementParser do
  let(:statement_text) { "not((not(a) ⊃ b) ≡ c)"}

  describe '#initialize' do

    describe '#statement_to_array' do
      context 'valid statement' do
        it 'returns a list of constants and operators and parentheses' do
          statement_text = "((A ⊃ B) ≡ (C or (B and D)))"
          parser = described_class.new(statement_text)
          expect(parser.statement_text).to eq (["(", "(", "a", "⊃", "b", ")", "≡", "(", "c", "or", "(", "b", "and", "d", ")", ")", ")"])
        end
      end
    end
    describe 'invalid statement texts' do
      context 'missing parenthesis' do
        it 'raises argument error' do
          statement_text = "((A ⊃ B) ≡ C"
          expect do
            described_class.new(statement_text)
          end.to raise_error(ArgumentError)
        end
      end
      context 'atomic statement joined by multiple operators' do
        it 'raises argument error' do
          statement_text = "(A ⊃ B ≡ C)"
          expect do
            described_class.new(statement_text)
          end.to raise_error(ArgumentError)
        end
      end
      context 'missing operator' do
        it 'raises argument error' do
          statement_text = "((A B) ≡ C"
          expect do
            described_class.new(statement_text)
          end.to raise_error(ArgumentError, "Missing connecting operator")
        end
      end
      context 'invalid symbols' do
        it 'raises argument error' do
          statement_text = "~([A ⊃ B] ≡ C)"
          expect do
            described_class.new(statement_text)
          end.to raise_error(ArgumentError, "Statement contains an invalid symbol: ~[]")
        end
      end
    end
  end

  describe '#removes_parentheses' do
    it 'removes outer most parentheses' do
      parser = described_class.new("")
      statement_list = ["(", "A", "or", "B", ")"]

      expect(parser.remove_parentheses(statement_list)).to eq ["A", "or", "B"]
    end
  end

  describe '#find_outer_operator_idx' do
    it 'finds the outer most operator' do
      parser = described_class.new("")
      statement_list = statement_list = ["(", "A", "or", "B", ")", "or", "C"]
      expect(parser.find_outer_operator_idx(statement_list)).to eq 5
    end
    context 'connecting two complex statements' do
      it do
        parser = described_class.new("")
        statement_list = statement_list = ["(", "A", "or", "B", ")", "or", "(", "C", "and", "D", ")"]
        expect(parser.find_outer_operator_idx(statement_list)).to eq 5
      end
    end
    context 'complex statements inside complex statements' do
      it do
        parser = described_class.new("")
        statement_list = statement_list = ["(", "A", "or", "(", "B", "or", "C", ")", ")", "or", "(", "C", "and", "D", ")"]
        expect(parser.find_outer_operator_idx(statement_list)).to eq 9
      end
    end
  end

  describe '#parentheses_match?' do
    it do
      parser =  described_class.new("")
      statement_list = ["(", "(", "a", "or", "b", ")", "and", "(", "c", "or", "d", ")", ")"]
      expect(parser.parentheses_match?(statement_list, 0, 12)).to be true
    end
  end

  describe '#parse' do
    let(:a) { MyKen::Statements::AtomicStatement.new(true, "a") }
    let(:b) { MyKen::Statements::AtomicStatement.new(true, "b") }
    let(:c) { MyKen::Statements::AtomicStatement.new(true, "c") }
    let(:d) { MyKen::Statements::AtomicStatement.new(true, "d") }
    context 'parses atomic statement' do
      it do
        parser = described_class.new("a")
        expect(parser.run).to eq a
      end
    end
    context 'parses conditional statement' do
      it do
        parser = described_class.new("a ⊃ b")

        expected_statement = MyKen::Statements::ComplexStatement.new(a, b, "⊃")
        expect(parser.run).to eq expected_statement
      end
    end
    context 'parses negation statement' do
      it do
        parser = described_class.new("not(a)")

        expected_statement = MyKen::Statements::ComplexStatement.new(a, nil, "not")
        expect(parser.run).to eq expected_statement
      end
    end
    context 'parses AND statement' do
      it do
        parser = described_class.new("a and b")

        expected_statement = MyKen::Statements::ComplexStatement.new(a, b, "and")
        expect(parser.run).to eq expected_statement
      end
    end
    context 'parses OR statement' do
      it do
        parser = described_class.new("a or b")

        expected_statement = MyKen::Statements::ComplexStatement.new(a, b, "or")
        expect(parser.run).to eq expected_statement
      end
    end
    context 'parses two complex statements' do
      it do
        parser = described_class.new("(a or b) and (c or d)")

        a_or_b = MyKen::Statements::ComplexStatement.new(a, b, "or")
        c_or_d = MyKen::Statements::ComplexStatement.new(c, d, "or")
        expected_statement = MyKen::Statements::ComplexStatement.new(a_or_b, c_or_d, "and")

        expect(parser.run).to eq expected_statement
      end
    end
    context 'parses nested complex statements' do
      it do
        parser = described_class.new("(a or ((a or b) and (c or d)))")

        a_or_b = MyKen::Statements::ComplexStatement.new(a, b, "or")
        c_or_d = MyKen::Statements::ComplexStatement.new(c, d, "or")
        a_or_b_and_c_or_d = MyKen::Statements::ComplexStatement.new(a_or_b, c_or_d, "and")
        expected_statement = MyKen::Statements::ComplexStatement.new(a, a_or_b_and_c_or_d, "or")

        expect(parser.run).to eq expected_statement
      end
    end
    context 'parses words as sentential constants' do
      it do
        parser = described_class.new("(Blueberries and Flour) ⊃ Pancakes")
        blueberries = MyKen::Statements::AtomicStatement.new(true, "blueberries")
        flour = MyKen::Statements::AtomicStatement.new(true, "flour")
        pancakes = MyKen::Statements::AtomicStatement.new(true, "pancakes")
        blueberries_and_flour = MyKen::Statements::ComplexStatement.new(blueberries, flour, "and")
        blueberries_and_flour_then_pancakes = MyKen::Statements::ComplexStatement.new(blueberries_and_flour, pancakes, "⊃")

        expect(parser.run).to eq blueberries_and_flour_then_pancakes
      end
      it do
        parser = described_class.new("((Blueberries and not(Flour)) and Oatmeal) ≡ (Pancakes and Oatmeal)")
        oatmeal = MyKen::Statements::AtomicStatement.new(true, "oatmeal")
        blueberries = MyKen::Statements::AtomicStatement.new(true, "blueberries")
        flour = MyKen::Statements::AtomicStatement.new(true, "flour")
        not_flour = MyKen::Statements::ComplexStatement.new(flour, nil, "not")
        pancakes = MyKen::Statements::AtomicStatement.new(true, "pancakes")
        blueberries_and_not_flour = MyKen::Statements::ComplexStatement.new(blueberries, not_flour, "and")
        blueberries_and_not_flour_and_oatmeal = MyKen::Statements::ComplexStatement.new(blueberries_and_not_flour, oatmeal, "and")
        pancakes_and_oatmeal = MyKen::Statements::ComplexStatement.new(pancakes, oatmeal, "and")
        expected_statement = MyKen::Statements::ComplexStatement.new(blueberries_and_not_flour_and_oatmeal, pancakes_and_oatmeal, "≡")

        expect(parser.run).to eq expected_statement
      end
      it do
        parser = described_class.new("not(flour) ⊃ (oatmeal and guargum)")

        flour = MyKen::Statements::AtomicStatement.new(true, "flour")
        not_flour = MyKen::Statements::ComplexStatement.new(flour, nil, "not")
        oatmeal = MyKen::Statements::AtomicStatement.new(true, "oatmeal")
        guargum = MyKen::Statements::AtomicStatement.new(true, "guargum")
        oatmeal_and_guargum = MyKen::Statements::ComplexStatement.new(oatmeal, guargum, "and")
        expected_statement = MyKen::Statements::ComplexStatement.new(not_flour, oatmeal_and_guargum, "⊃")
        expect(parser.run).to eq expected_statement
      end
    end
  end
end
