require 'spec_helper'

describe RuleRover::FirstOrderLogic::Sentences::Variable do
  it 'does not raise' do
    expect { described_class.new('a') }.not_to raise_error
  end

  describe '.valid_name?' do
    it 'returns true for a lower letter string' do
      expect(described_class.valid_name?('a')).to be(true)
    end
    it 'returns false for a predicate name' do
      expect(described_class.valid_name?(:x)).to be(false)
    end
    it do
      expect(described_class.valid_name?("foobar")).to be(true)
    end
  end
end