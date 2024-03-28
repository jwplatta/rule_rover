require 'spec_helper'

describe RuleRover::FirstOrderLogic::Sentences::ConstantSymbol do
  it 'does not raise' do
    expect { described_class.new('Aristotle') }.not_to raise_error
  end
end