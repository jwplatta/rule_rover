require 'spec_helper'

describe RuleRover::PropositionalLogic::Sentences::Atomic do
  it 'does not raise' do
    expect { described_class.new(nil) }.not_to raise_error
  end
end