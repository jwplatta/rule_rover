require 'spec_helper'

describe MyKen::Statements do
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
