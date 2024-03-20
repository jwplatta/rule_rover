require 'spec_helper'

describe RuleRover::PropositionalLogic::Sentences::Conjunction do
  it 'does not raise' do
    expect { described_class.new(nil, nil) }.not_to raise_error
  end
end