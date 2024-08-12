require "spec_helper"

describe RuleRover::VERSION do
  it "returns current version" do
    expect(subject).to eq "0.1.0.dev"
  end
end
