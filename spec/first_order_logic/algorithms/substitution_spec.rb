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
    xcontext 'when given a conjunction with the same constants' do
      it 'returns an empty substitution' do
        binding.pry
        expect(
          described_class.run(
            sentence_factory.build('Joe', :and, 'Maureen'),
            sentence_factory.build('Joe', :and, 'Maureen'),
            {}
          )
        ).to eq({})
      end
    end
    xcontext 'when given a conjunction with different constants' do
      it 'returns false' do
        expect(
          described_class.run(
            sentence_factory.build('Joe', :and, 'Matt'),
            sentence_factory.build('Joe', :and, 'Maureen'),
            {}
          )
        ).to eq(false)
      end
    end
    xcontext 'when given a conjunction with a variable' do
      it 'returns a substitution' do
        expect(
          described_class.run(
            sentence_factory.build('Joe', :and, 'Matt'),
            sentence_factory.build('Joe', :and, 'x'),
            {}
          )
        ).to eq({
          sentence_factory.build('x') => sentence_factory.build('Matt')
        })
      end
    end
    xcontext 'when given a conjunction with a variable' do
      it 'returns a substitution' do
        expect(
          described_class.run(
            sentence_factory.build('x', :and, 'Matt'),
            sentence_factory.build('Joe', :and, 'x'),
            {}
          )
        ).to eq({
          sentence_factory.build('x_1') => sentence_factory.build('Joe'),
          sentence_factory.build('x_2') => sentence_factory.build('Matt')
        })
      end
    end
    xcontext 'when given a conjunction with different constants' do
      it 'returns a substitution' do
        expected = {
          sentence_factory.build('x_1') => sentence_factory.build('Joe'),
          sentence_factory.build('x_2') => sentence_factory.build('Maureen')
        }
        expect(
          described_class.run(
            sentence_factory.build('Joe', :and, 'Maureen'),
            sentence_factory.build('Joe', :and, 'Maureen'),
            {}
          )
        ).to eq({})
      end
    end
  end
  describe '.is_variable?' do
    context 'when the expression is a variable' do
      it 'returns true' do
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
