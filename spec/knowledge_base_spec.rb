require 'spec_helper'

describe MyKen::KnowledgeBase do
  describe '#initialize' do
    it do
      statements = lambda do |a, b|
        complex_statements = [(a or b), not(a and b)]
        ([a, b] + complex_statements).reduce(:'|')
      end

      kb = MyKen::KnowledgeBase.new(statements: statements)
      expect(kb.statements).to be_instance_of(Proc)
    end
  end


  describe '#is_true?' do
    context 'when false for a given model' do
      it '' do
        statements = lambda do |a, b|
          complex_statements = [(a or b)]
          ([a, b] + complex_statements).reduce(:'|')
        end

        kb = MyKen::KnowledgeBase.new(statements: statements)
        model = [false, false]

        expect(kb.true?(model)).to eq false
      end

      context 'when lots of complex statements' do
        it 'is true' do
          statements = lambda do |a, b, c|
            complex_statements = [
              (a or b),
              ((c.⊃ b) and not(b.⊃ c))
            ]
            ([a, b, c] + complex_statements).reduce(:'|')
          end

          kb = MyKen::KnowledgeBase.new(statements: statements)
          model = [false, false, false]

          expect(kb.true?(model)).to eq false
        end
      end
    end

    context 'when false for a given model' do
      it 'is true' do
        statements = lambda do |a, b|
          complex_statements = [(a or b)]
          ([a, b] + complex_statements).reduce(:'|')
        end

        kb = MyKen::KnowledgeBase.new(statements: statements)
        model = [true, false]

        expect(kb.true?(model)).to eq true
      end
    end
  end
end
