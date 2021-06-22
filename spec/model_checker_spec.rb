require 'spec_helper'

describe MyKen::ModelChecker do
  context 'simple knowledge base' do
    let(:as1) do
      MyKen::Statements::AtomicStatement.new(true)
    end
    let(:as2) do
      MyKen::Statements::AtomicStatement.new(true)
    end
    let(:statements) do
      [
        as1,
        as2,
        cs1 = MyKen::Statements::ComplexStatement.new(as1, as2, '⊃')
      ]
    end
    let(:cs2) do
      not_as2 = MyKen::Statements::ComplexStatement.new(as2, nil, 'not')
      MyKen::Statements::ComplexStatement.new(as1, not_as2, 'and')
    end
    let(:kb) do
      MyKen::KnowledgeBase.new do |kb|
        statements.each { |s| kb.add_fact(s) }
      end
    end
    context 'KB entails alpha' do
      it 'returns true' do
        expect(MyKen::ModelChecker.run(kb, as2)).to be true
      end
    end
    context 'KB does not entail alpha' do
      it 'returns false' do
        expect(MyKen::ModelChecker.run(kb, cs2)).to be false
      end
    end
  end
end
