require 'spec_helper'

describe RuleRover::KnowledgeBase do
  let(:statements) do
    [
      as1 = RuleRover::Statements::AtomicStatement.new(true, :as1),
      as2 = RuleRover::Statements::AtomicStatement.new(false, :as2),
      as3 = RuleRover::Statements::AtomicStatement.new(false, :as3),
      cs1 = RuleRover::Statements::ComplexStatement.new(as1, as2, 'and'),
      cs2 = RuleRover::Statements::ComplexStatement.new(as1, as3, 'or'),
      cs3 = RuleRover::Statements::ComplexStatement.new(cs1, cs2, 'or')
    ]
  end
  let(:kb) do
    described_class.new do |kb|
      statements.each { |s| kb.add_fact(s) }
    end
  end
  describe '#initialize' do
    it do
      expect(kb.statements.count).to eq statements.count
      expect(kb.atomic_statements.count).to eq 3
    end
  end
  describe '#to_s' do
    it do
      expect(kb.to_s).to eq "as1: true\nas2: false\nas3: false\n(as1 and as2)\n(as1 or as3)\n((as1 and as2) or (as1 or as3))"
    end
  end
  describe '#update_model' do
    it 'changes values of atomic statements' do
      new_model = [false, true, true]
      kb.update_model(*new_model)

      expect(kb.atomic_statements.map(&:value)).to eq new_model
    end
  end
  describe '#value' do
    it 'returns true' do
      new_model = [false, false, false]
      kb.update_model(*new_model)
      expect(kb.value).to be false
    end

    it 'returns false' do
      new_model = [true, true, true]
      kb.update_model(*new_model)
      expect(kb.value).to be true
    end
  end


  describe 'predicate knowledge base' do
    context '#assert' do
      context 'validations' do
        it 'raises when not a definite clause' do
          predicate_kb = RuleRover::PredicateKB.new
          predicate_x = RuleRover::Statements::Predicate.new(identifier: "Understands", assignments: { "a" => nil, "b" => nil })
          predicate_y = RuleRover::Statements::Predicate.new(identifier: "Agrees", assignments: { "c" => nil, "d" => nil })
          expect do
            predicate_kb.assert(predicate_x.not.and(predicate_y.not))
          end.to raise_error(ArgumentError)
        end
      end
      it 'adds single predicate' do
        predicate_kb = RuleRover::PredicateKB.new
        predicate_x = RuleRover::Statements::Predicate.new(identifier: "Understands", assignments: { "a" => nil, "b" => nil })
        predicate_kb.assert(predicate_x)
        expect(predicate_kb.clauses.size).to eq 1
      end
      it 'adds complex statement' do
        predicate_kb = RuleRover::PredicateKB.new
        predicate_x = RuleRover::Statements::Predicate.new(identifier: "Understands", assignments: { "a" => nil, "b" => nil })
        predicate_y = RuleRover::Statements::Predicate.new(identifier: "Agrees", assignments: { "c" => nil, "d" => nil })
        predicate_kb.assert(predicate_x.or(predicate_y.not))
        expect(predicate_kb.clauses.size).to eq 1
      end
    end
    context '#deny' do
      it 'removes a single predicate' do
        predicate_kb = RuleRover::PredicateKB.new
        predicate_x = RuleRover::Statements::Predicate.new(identifier: "Understands", assignments: { "a" => nil, "b" => nil })
        predicate_kb.assert(predicate_x)
        predicate_kb.deny(predicate_x)
        expect(predicate_kb.clauses.size).to eq 0
      end
      it 'removes complex statement' do
        predicate_kb = RuleRover::PredicateKB.new
        predicate_x = RuleRover::Statements::Predicate.new(identifier: "Understands", assignments: { "a" => nil, "b" => nil })
        predicate_y = RuleRover::Statements::Predicate.new(identifier: "Agrees", assignments: { "c" => nil, "d" => nil })
        predicate_kb.assert(predicate_x.or(predicate_y.not))
        predicate_kb.deny(predicate_x.or(predicate_y.not))
        expect(predicate_kb.clauses.size).to eq 0
      end
      it 'removes complex statement with conjuncts' do
        predicate_kb = RuleRover::PredicateKB.new
        predicate_x = RuleRover::Statements::Predicate.new(identifier: "Understands", assignments: { "a" => nil, "b" => nil })
        predicate_y = RuleRover::Statements::Predicate.new(identifier: "Agrees", assignments: { "c" => nil, "d" => nil })
        predicate_z = RuleRover::Statements::Predicate.new(identifier: "Dismisses", assignments: { "e" => nil, "f" => nil })
        predicate_kb.assert(predicate_x.or(predicate_y.not))
        predicate_kb.assert(predicate_z)
        predicate_kb.deny(predicate_x.or(predicate_y.not).and(predicate_z))
        expect(predicate_kb.clauses.size).to eq 0
      end
    end
    context '#constants' do
      it do
        predicate_kb = RuleRover::PredicateKB.new
        predicate_x = RuleRover::Statements::Predicate.new(identifier: "Understands", assignments: { "a" => "Peter", "b" => nil })
        predicate_y = RuleRover::Statements::Predicate.new(identifier: "Agrees", assignments: { "c" => nil, "d" => "Peter" })
        predicate_z = RuleRover::Statements::Predicate.new(identifier: "Dismisses", assignments: { "e" => "Paul", "f" => "Mary" })
        stmt = predicate_x.not.or(predicate_y.not).or(predicate_z)

        predicate_kb.assert(stmt)

        expect(predicate_kb.constants.sort).to eq ["Mary", "Paul", "Peter"]
      end
    end
  end
end
