require 'spec_helper'

describe RuleRover::FirstOrderLogic::Algorithms::Substitution do
  describe '.find' do
    context 'when given two variables' do
      it 'returns a substitution' do
        expect(
          described_class.find(
            sentence_factory.build('x'),
            sentence_factory.build('x')
          )
        ).to eq({})
      end
    end
    context 'when given a variable and a constant' do
      it 'returns a substitution' do
        example_one =  described_class.find(
          sentence_factory.build('x'),
          sentence_factory.build('Maureen')
        )
        expected = {
          sentence_factory.build('x_1') => sentence_factory.build('Maureen')
        }

        expect(example_one).to eq(expected)

        example_two = described_class.find(
          sentence_factory.build('Maureen'),
          sentence_factory.build('x')
        )

        expect(example_two).to eq(expected)
      end
    end
    context 'when given two predicates' do
      it 'returns a substitution' do
        sent1 = sentence_factory.build('x', :taught, 'Aristotle')
        sent2 = sentence_factory.build('Plato', :taught, 'x')
        expected = {
          sentence_factory.build('x_1') => sentence_factory.build('Plato'),
          sentence_factory.build('x_2') => sentence_factory.build('Aristotle')
        }

        substitution = described_class.find(sent1, sent2)
        expect(substitution).to eq(expected)
      end
    end
    context 'when given two functions' do
      it 'returns a substitution' do
        sent1 = sentence_factory.build(:@son_of, 'Peter', 'x')
        sent2 = sentence_factory.build(:@son_of, 'x', 'Mary')
        expected = {
          sentence_factory.build('x_1') => sentence_factory.build('Peter'),
          sentence_factory.build('x_2') => sentence_factory.build('Mary')
        }

        substitution = described_class.find(sent1, sent2)
        expect(substitution).to eq(expected)
      end
    end
    context 'when given a function and a predicate' do
      it 'returns false' do
        sent1 = sentence_factory.build(:@son_of, 'Peter', 'x')
        sent2 = sentence_factory.build('Plato', :taught, 'x')
        substitution = described_class.find(sent1, sent2)
        expect(substitution).to eq(false)
      end
    end
    context 'when given a conjunction with the same constants' do
      it 'returns an empty substitution' do
        expect(
          described_class.find(
            sentence_factory.build('Joe', :and, 'Maureen'),
            sentence_factory.build('Joe', :and, 'Maureen')
          )
        ).to eq({})
      end
    end
    context 'when given a conjunction with different constants' do
      it 'returns false' do
        expect(
          described_class.find(
            sentence_factory.build('Joe', :and, 'Matt'),
            sentence_factory.build('Joe', :and, 'Maureen')
          )
        ).to eq(false)
      end
    end
    context 'when given a conjunction with a constants and a function' do
      it 'returns a substitution' do
        substitution = described_class.find(
          sentence_factory.build('Joe', :and, 'Matt'),
          sentence_factory.build('Joe', :and, [:@brother_of, 'x'])
        )
        expect(
          substitution
        ).to eq(false)
      end
    end
    context 'when given a conjunction with a variables' do
      it 'returns a substitution' do
        substitution = described_class.find(
          sentence_factory.build('x', :and, 'Matt'),
          sentence_factory.build('Joe', :and, 'x')
        )
        expect(substitution).to eq({
          sentence_factory.build('x_1') => sentence_factory.build('Joe'),
          sentence_factory.build('x_2') => sentence_factory.build('Matt')
        })
      end
    end
    context 'when given a biconditional with predicates' do
      it 'returns a substitution' do
        substitution = described_class.find(
          sentence_factory.build('Joe', :iff, ['Plato', :taught, 'x']),
          sentence_factory.build('Joe', :iff, ['x', :taught, 'Aristotle'])
        )
        expected = {
          sentence_factory.build('x_2') => sentence_factory.build('Plato'),
          sentence_factory.build('x_3') => sentence_factory.build('Aristotle')
        }
        expect(substitution).to eq(expected)
      end
    end
    context 'when given a disjunction with functions' do
      it 'returns a substitution' do
        substitution = described_class.find(
          sentence_factory.build('Matt', :or, [:@son_of, 'Peter', 'x']),
          sentence_factory.build('Matt', :or, [:@son_of, 'y', 'Mary'])
        )
        expected = {
          sentence_factory.build('x_2') => sentence_factory.build('Peter'),
          sentence_factory.build('x_3') => sentence_factory.build('Mary')
        }
        expect(substitution).to eq(expected)
      end
    end
    context 'when given a negation with functions' do
      it 'returns a substitution' do
        substitution = described_class.find(
          sentence_factory.build(:not, [:@son_of, 'Peter', 'x']),
          sentence_factory.build(:not, [:@son_of, 'y', 'Mary'])
        )
        expected = {
          sentence_factory.build('x_1') => sentence_factory.build('Peter'),
          sentence_factory.build('x_2') => sentence_factory.build('Mary')
        }
        expect(substitution).to eq(expected)
      end
    end
  end
  describe '.is_variable?' do
    context 'when the expression is a variable' do
      xit 'returns true' do
        expect(
          described_class.is_variable?(
            sentence_factory.build('x')
          )
        ).to be true
      end
    end
    context 'when the expression is not a variable' do
    end
  end

  def sentence_factory
    RuleRover::FirstOrderLogic::Sentences::Factory
  end
end
