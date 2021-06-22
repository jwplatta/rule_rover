require 'spec_helper'

describe MyKen::KnowledgeBase do
  let(:statements) do
    [
      as1 = MyKen::Statements::AtomicStatement.new(true, :as1),
      as2 = MyKen::Statements::AtomicStatement.new(false, :as2),
      as3 = MyKen::Statements::AtomicStatement.new(false, :as3),
      cs1 = MyKen::Statements::ComplexStatement.new(as1, as2, 'and'),
      cs2 = MyKen::Statements::ComplexStatement.new(as1, as3, 'or'),
      cs3 = MyKen::Statements::ComplexStatement.new(cs1, cs2, 'or')
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
end
