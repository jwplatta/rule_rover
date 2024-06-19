require "spec_helper"

describe RuleRover::FirstOrderLogic::Action do
  it "does not raise" do
    expect { described_class.new(proc {}) }.not_to raise_error
  end
  describe "#initialize" do
    context "when the function parameters are not keyword parameters" do
      it "raises an error" do
        expect do
          described_class.new(
            proc { |param1| puts param1 },
            name: :action1,
            param_names: [:param1]
          )
        end.to raise_error(ArgumentError)
      end
    end
    context "when the function parameters match the param_names" do
      it "does not raise" do
        new_action = described_class.new(
          proc { |param1:| puts param1 },
          name: :action1,
          param_names: [:param1]
        )
        expect(new_action).to be_a(RuleRover::FirstOrderLogic::Action)
        expect(new_action.name).to eq(:action1)
        expect(new_action.param_names).to eq([:param1])
      end
    end
  end
  describe "#call" do
    let(:action) do
      described_class.new(
        proc { |param1:| param1 },
        name: :action1,
        param_names: [:param1]
      )
    end
    context "when the parameters are missing" do
      it "raises an error" do
        expect { action.call(**{}) }.to raise_error(ArgumentError)
      end
    end
    context "when the parameters are present" do
      it "calls the function" do
        expect(action.call(param1: "value")).to eq("value")
      end
    end
  end
end
