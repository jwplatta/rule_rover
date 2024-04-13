require 'spec_helper'

describe RuleRover::FirstOrderLogic::Algorithms::Unification do
  it 'does not raise' do
    expect { described_class.run(nil, nil, {}) }.not_to raise_error
  end

  describe '.run' do
    context 'when subsitution is false' do
      it 'returns false' do
        expect(described_class.run('x', 'y', false)).to be(false)
      end
    end
    context 'when given two variables' do
      context 'when the variables are the same' do
        fit 'returns a substitution' do
          expect(described_class.run('x', 'x', {})).to eq({})
        end
      end
      context 'when the variables are different' do
      end
    end
  end
end
