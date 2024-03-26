require 'spec_helper'

describe RuleRover::PropositionalLogic::Sentences::Atomic do
  it 'does not raise' do
    expect { described_class.new(nil) }.not_to raise_error
  end

  describe '#evaluate' do
    it 'returns the value of the atomic sentence in the model' do
      atomic = described_class.new("a")
      expect(atomic.evaluate({ "a" => true })).to be true
      expect(atomic.evaluate({ "a" => false })).to be false
    end
  end
end