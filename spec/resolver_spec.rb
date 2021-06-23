require 'spec_helper'

describe MyKen::Resolver do
  let(:b) { MyKen::Statements::AtomicStatement.new(true, "b") }
  let(:not_b) { MyKen::Statements::ComplexStatement.new(b, nil, "not") }
  let(:p1) { MyKen::Statements::AtomicStatement.new(true, "p1") }
  let(:p2) { MyKen::Statements::AtomicStatement.new(true, "p2") }
  let(:not_p2) { MyKen::Statements::ComplexStatement.new(p2, nil, "not") }
  let(:p3) { MyKen::Statements::AtomicStatement.new(true, "p3") }
  let(:not_p3) { MyKen::Statements::ComplexStatement.new(p3, nil, "not") }
  let(:p1_or_p2) { MyKen::Statements::ComplexStatement.new(p1, p2, "or") }
  let(:p1_or_p2_or_p3) { MyKen::Statements::ComplexStatement.new(p1_or_p2, p3, "or") }
  let(:p1_or_p3) { MyKen::Statements::ComplexStatement.new(p1, p3, "or") }
  let(:b_bicond_p1_or_p2_or_p3) { MyKen::Statements::ComplexStatement.new(b, p1_or_p2_or_p3, "≡") }
  let(:b_bicond_p1_or_p2) { MyKen::Statements::ComplexStatement.new(b, p1_or_p2, "≡") }
  let(:kb) do
    MyKen::KnowledgeBase.new do |kb|
      kb.add_fact(b_bicond_p1_or_p2)
    end
  end
  let(:resolver) { resolver = described_class.new(knowledge_base: kb, statement: p2) }

  describe '#initialize' do
    context 'when not provided a knowledge base and a statement' do
      it 'it raises' do
        expect do
          described_class.new()
        end.to raise_error(ArgumentError)
      end
    end
  end
  describe '#knowledge_base_statement' do
    it 'converts knowledge base to single statement' do
      resolver = described_class.new(knowledge_base: kb, statement: p2)
    end
  end
  describe '#statement_clauses' do
    it '' do
      clauses = resolver.parse_clauses(resolver.to_conjunctive_normal_form)
    end
  end

  describe '#resolve' do
    context 'modus ponens' do
      let(:simple_kb) do
        MyKen::KnowledgeBase.new do |kb|
          kb.add_fact(MyKen::Statements::ComplexStatement.new(p1, p2, '⊃'))
          kb.add_fact(p1)
        end
      end
      it 'resolves to true' do
        resolver = described_class.new(knowledge_base: simple_kb, statement: p2)
        expect(resolver.resolve).to be true
      end
      it 'resolves to false' do
        not_p1 = MyKen::Statements::ComplexStatement.new(p1, nil, 'not')
        resolver = described_class.new(knowledge_base: simple_kb, statement: not_p1)
        expect(resolver.resolve).to be false
      end
    end
    context 'modus tollens' do
      let(:simple_kb) do
        MyKen::KnowledgeBase.new do |kb|
          kb.add_fact(MyKen::Statements::ComplexStatement.new(p1, p2, '⊃'))
          kb.add_fact(not_p2)
        end
      end
      it 'resolves to true' do
        not_p1 = MyKen::Statements::ComplexStatement.new(p1, nil, 'not')
        resolver = described_class.new(knowledge_base: simple_kb, statement: not_p1)
        expect(resolver.resolve).to be true
      end
      it 'resolves to false' do
        resolver = described_class.new(knowledge_base: simple_kb, statement: p1)
        expect(resolver.resolve).to be false
      end
    end
    context 'complex knowledge bases' do
      context 'complex kb with conditionals' do
        let(:complex_kb) do
          MyKen::KnowledgeBase.new do |kb|
            kb.add_fact(MyKen::Statements::ComplexStatement.new(p1, p2, '⊃'))
            kb.add_fact(MyKen::Statements::ComplexStatement.new(p2, p3, '⊃'))
            kb.add_fact(p1)
          end
        end
        it 'resolves to true' do
          resolver = described_class.new(knowledge_base: complex_kb, statement: p3)
          expect(resolver.resolve).to be true
        end
        it 'resolves to false' do
          not_p1 = MyKen::Statements::ComplexStatement.new(p1, nil, 'not')
          resolver = described_class.new(knowledge_base: complex_kb, statement: not_p1)
          expect(resolver.resolve).to be false
        end
      end
      context 'complex knowledge base with disjunction' do
        let(:p4) { MyKen::Statements::AtomicStatement.new(true, "p4") }

        let(:complex_kb) do
          # NOTE: proof
          #   (p3 and p4) or (p1 and p2)
          #   not(p1 and p2)
          #   p3 and p4
          #   p4
          MyKen::KnowledgeBase.new do |kb|
            p3_and_p4 = MyKen::Statements::ComplexStatement.new(p3, p4, 'and')
            p1_and_p2 = MyKen::Statements::ComplexStatement.new(p1, p2, 'and')
            p1_and_p2_or_p3_and_p4 = MyKen::Statements::ComplexStatement.new(p1_and_p2, p3_and_p4, 'or')
            not_p1_and_p2 = MyKen::Statements::ComplexStatement.new(p1_and_p2, nil, 'not')

            kb.add_fact(p1_and_p2_or_p3_and_p4)
            kb.add_fact(not_p1_and_p2)
          end
        end
        it 'resolves' do
          resolver = described_class.new(knowledge_base: complex_kb, statement: p4)
          expect(resolver.resolve).to be true
        end
      end
      context 'slow query' do
        let(:pancakes) { parse_string_to_statement("pancakes") }
        let(:blueberries) { parse_string_to_statement("blueberries") }
        # not(flour) ⊃ (oatmeal and guargum)
        let(:not_flour_then_oatmeal_and_guargum) do
          parse_string_to_statement("not(flour) ⊃ (oatmeal and guargum)")
        end
        # not(oatmeal and guargum)
        let(:not_oatmeal_and_guargum) do
          parse_string_to_statement("not(oatmeal and guargum)")
        end
        let(:blueberries_and_flour_then_pancakes) do
          parse_string_to_statement("(blueberries and flour) ⊃ pancakes")
        end
        let(:kb) do
          MyKen::KnowledgeBase.new do |kb|
            kb.add_fact(not_oatmeal_and_guargum)
            kb.add_fact(blueberries)
            kb.add_fact(not_flour_then_oatmeal_and_guargum)
            kb.add_fact(blueberries_and_flour_then_pancakes)
          end
        end
        it 'resolves' do
          resolver = described_class.new(knowledge_base: kb, statement: pancakes)
          expect(resolver.resolve).to be true
        end
        context 'unrelated atomic statement' do
          let(:lemon) { parse_string_to_statement("lemon") }
          it 'resolves to false' do
            resolver = described_class.new(knowledge_base: kb, statement: lemon)
            expect(resolver.resolve).to be false
          end
        end
        context 'unrelated complex statement' do
          let(:lemon_or_oatmeal) { parse_string_to_statement("lemon or oatmeal") }
          it 'resolves to false' do
            resolver = described_class.new(knowledge_base: kb, statement: lemon_or_oatmeal)
            expect(resolver.resolve).to be false
          end
        end
      end
    end
    context 'when words used as sentential constants' do
      let(:pancakes) { parse_string_to_statement("Pancakes") }
      let(:oatmeal) { parse_string_to_statement("Oatmeal") }
      let(:blueberries) { parse_string_to_statement("Blueberries") }
      let(:flour) { parse_string_to_statement("Flour") }
      let(:flour_and_blueberries) { parse_string_to_statement("Flour and Blueberries") }
      let(:flour_and_blueberries_then_pancakes) { parse_string_to_statement("(Flour and Blueberries) ⊃ Pancakes") }
      let(:kb) do
        MyKen::KnowledgeBase.new do |kb|
          kb.add_fact(flour_and_blueberries_then_pancakes)
          kb.add_fact(flour_and_blueberries)
        end
      end
      it 'resolves' do
        resolver = described_class.new(knowledge_base: kb, statement: pancakes)
        expect(resolver.resolve).to be true
      end
    end
  end

  describe '#join_clauses' do
    context 'when not passed an array' do
      it 'raises' do
        expect do
          resolver.join_clauses(b)
        end.to raise_error(ArgumentError)
      end
    end
    context 'when only 1 clause' do
      it 'returns the 1 clause' do
        expect(resolver.join_clauses([b])).to eq b
      end
    end
    context 'when 2 clauses' do
      it 'returns a disjunction of the clauses' do
        b_or_p1 = MyKen::Statements::ComplexStatement.new(b, p1, "or")
        expect(resolver.join_clauses([b, p1])).to eq b_or_p1
      end
    end
    context 'when more than 2 clauses' do
      it 'returns a disjunction of the clauses' do
        b_or_p1 = MyKen::Statements::ComplexStatement.new(b, p1, "or")
        b_or_p1_or_p2 = MyKen::Statements::ComplexStatement.new(b_or_p1, p2, "or")
        b_or_p1_or_p2_or_p3 = MyKen::Statements::ComplexStatement.new(b_or_p1_or_p2, p3, "or")
        expect(resolver.join_clauses([b, p1, p2, p3])).to eq b_or_p1_or_p2_or_p3
      end
    end
  end

  describe '#resolve_clauses' do
    context 'when clauses contain complimentary literals' do
      context 'when only complimentary literals' do
        it 'removes the complimentary literals' do
          result = resolver.resolve_clauses(p2, not_p2)
          expect(result).to eq ([])
        end
      end
      context 'when some complimentary literals' do
        it 'removes the complimentary literals' do
          p2_or_not_p3 = MyKen::Statements::ComplexStatement.new(p2, not_p3, "or")
          p1_or_not_p2 = MyKen::Statements::ComplexStatement.new(p1, not_p2, "or")
          result = resolver.resolve_clauses(p2_or_not_p3, p1_or_not_p2)
          expect(result).to eq ([not_p3, p1])
        end
      end
    end
    context 'when clauses do not contain complimentary literals' do
      it 'does not remove any literals'
    end
  end

  describe '#unit_resolution' do
    context 'when complimentary literals' do
      it 'returns complimentary literals' do
        expect(resolver.unit_resolution(p2, not_p2)).to eq ([p2, not_p2])
      end
    end
    context 'when no complimentary literals' do
      it 'does not remove any literals' do
        expect(resolver.unit_resolution(p2, p1)).to eq ([])
      end
    end
  end

  describe '#atomic_statements' do
    it 'returns an array of atomic statements' do
      resolver = described_class.new(knowledge_base: kb, statement: p2)
      statement = resolver.to_conjunctive_normal_form

      expect(resolver.atomic_statements(statement).count).to eq 8
    end
  end

  # REVIEW:
  xdescribe '#to_conjunctive_normal_form' do
    it 'converters the knowledge base and the not statement to CNF' do
      resolver = described_class.new(knowledge_base: kb, statement: p2)
      cnf_statement = resolver.to_conjunctive_normal_form
    end
  end
end

def parse_string_to_statement(statement_text)
  MyKen::StatementParser.parse(statement_text)
end
