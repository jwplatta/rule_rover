require "spec_helper"

describe RuleRover::FirstOrderLogic::Action do
  it "does not raise" do
    expect { described_class.new }.not_to raise_error
  end
end