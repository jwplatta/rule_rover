require "spec_helper"

describe RuleRover::FirstOrderLogic::ActionRegistry do
  fit "does not raise" do
    expect { described_class.new }.not_to raise_error
  end

  describe "#add" do
    context 'when adding a net action' do
      it 'returns the new action' do
      end
    end
    context 'when adding a net action that already exists' do
      it 'raises an error' do
      end
    end
  end

  describe '#map_rule_to_action' do
    context 'when the rule is not a conditional' do
      it 'raises an error' do
      end
    end
    context 'when the action does not exist' do
      it 'raises an error' do
      end
    end
    context 'when the rule is a conditional and action exists' do
      it 'maps the rule to the action' do
      end
    end
  end

  describe '#call' do
  end

  describe '#call_rule_actions' do
    context 'when rule has single action' do
    end
    context 'when rule has multiple actions' do
    end
  end
end
