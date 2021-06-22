require 'spec_helper'

describe MyKen::Resolver do
  let(:b) { MyKen::Statements::AtomicStatement.new(true, :b) }
  let(:not_b) { MyKen::Statements::ComplexStatement.new(b, nil, "not") }
  let(:p1) { MyKen::Statements::AtomicStatement.new(true, :p1) }
  let(:p2) { MyKen::Statements::AtomicStatement.new(true, :p2) }
  let(:not_p2) { MyKen::Statements::ComplexStatement.new(p2, nil, "not") }
  let(:p3) { MyKen::Statements::AtomicStatement.new(true, :p3) }
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
    context 'complex knowledge base' do
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