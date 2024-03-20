require 'spec_helper'

describe RuleRover::PropositionalLogic::Sentences::Sentence do
  it 'does not raise' do
    expect { described_class.new(nil, nil) }.not_to raise_error
  end
  it 'is not atomic' do
    expect(described_class.new(nil, nil).is_atomic?).to be false
  end
  it 'is not definite' do
    expect(described_class.new(nil, nil).is_definite?).to be false
  end
  it 'is not positive' do
    expect(described_class.new(nil, nil).is_positive?).to be false
  end

  describe '#to_cnf' do
    xit 'returns a sentence in cnf' do
    end
  end
end