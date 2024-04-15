require 'spec_helper'

describe RuleRover::FirstOrderLogic::Algorithms::Unification do
  it 'does not raise' do
    expect { described_class.run(nil, nil, {}) }.not_to raise_error
  end

  fdescribe '.run' do
    context 'when substitution is false' do
      it 'returns false' do
        expect(
          described_class.run(
            sentence_factory.build('x'),
            sentence_factory.build('y'),
            false
          )
        ).to be(false)
      end
    end
    context 'when given two variables' do
      context 'when the variables are the same' do
        it 'returns a substitution' do
          expect(
            described_class.run(
              sentence_factory.build('x'),
              sentence_factory.build('x'),
              {}
            )
          ).to eq({})
        end
      end
    end
    context 'when given a variable and a constant' do
      it 'returns a substitution' do
        expect(
          described_class.run(
            sentence_factory.build('x'),
            "Maureen",
            {}
          )
        ).to eq({ "x" => "Maureen" })

        expect(
          described_class.run(
            "Maureen",
            sentence_factory.build("x"),
            {}
          )
        ).to eq({ "x" => "Maureen" })
      end
    end
    context 'when given a constant and a compount statement' do
      fit 'returns a substitution' do
        expect(
          described_class.run(
            sentence_factory.build('x', :and, 'y'),
            "Maureen",
            { "x" => "Joe" }
          )
        ).to eq({ "x" => "Joe", "y" => "Maureen" })
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
