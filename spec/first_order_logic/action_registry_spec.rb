require "spec_helper"

describe RuleRover::FirstOrderLogic::ActionRegistry do
  it "does not raise" do
    expect { described_class.new }.not_to raise_error
  end

  describe "#add" do
    let(:action_registry) { described_class.new }
    let(:function) { proc { |x:| x * 2 } }
    context "when adding a net action" do
      it "returns the new action" do
        new_action = action_registry.add(:double, &function)

        expect(new_action).to be_a(RuleRover::FirstOrderLogic::Action)
        expect(new_action.name).to eq(:double)
        expect(new_action.param_names).to eq([:x])
        expect(new_action.func).to eq(function)
      end
    end
    context "when adding a new action that already exists" do
      it "raises an error" do
        action_registry.add(:double, &function)
        expect { action_registry.add(:double, &function) }.to raise_error(StandardError)
      end
    end
  end

  describe "#map_rule_to_action" do
    let(:rule) { sentence_factory.build([:@philosopher, "x"], :then, ["x", :knows, "y"]) }
    let(:not_a_rule) { sentence_factory.build([:@philosopher, "x"], :and, ["x", :knows, "Externalworld"]) }
    let(:function) { proc { |name:| puts name } }
    let(:action_registry) do
      described_class.new.tap do |act_reg|
        act_reg.add(:print_name, :name, &function)
      end
    end
    context "when the rule is not a conditional" do
      it "raises an error" do
        expect do
          action_registry.map_rule_to_action(not_a_rule, :print_name, **{ name: "x" })
        end.to raise_error(StandardError)
      end
    end
    context "when the action does not exist" do
      it "raises an error" do
        expect do
          action_registry.map_rule_to_action(not_a_rule, :not_an_action, **{ name: "x" })
        end.to raise_error(StandardError)
      end
    end
    context "when the rule is a conditional and action exists" do
      it "maps the rule to the action" do
        expect { action_registry.map_rule_to_action(rule, :print_name, **{ name: "x" }) }.to raise_error(StandardError)
      end
    end
  end

  describe "#call" do
    let(:rule) { sentence_factory.build([:@philosopher, "x"], :then, ["x", :knows, "Externalworld"]) }
    let(:function) { proc { |name:| name.capitalize } }
    let(:action_registry) do
      described_class.new.tap do |act_reg|
        act_reg.add(:capitalize_name, &function)
      end
    end
    it "calls the action" do
      expect(action_registry.call(:capitalize_name, **{ name: "hume" })).to eq("Hume")
    end
  end

  describe "#call_rule_actions" do
    let(:rule) { sentence_factory.build([:@philosopher, "x"], :then, ["x", :knows, "Externalworld"]) }
    let(:function_a) { proc { |name:| name.upcase } }
    let(:function_b) { proc { |name:| name.sub name, "Leibniz" } }

    context "when rule has single action" do
      it do
        action_registry = described_class.new.tap do |act_reg|
          act_reg.add(:upcase_name, &function_a)
          act_reg.map_rule_to_action(rule, :upcase_name, **{ name: "x" })
        end
        substitution = {
          sentence_factory.build("x_1") => sentence_factory.build("Hume")
        }
        std_rule = rule.standardize_apart(rule, reset_var_count: false)
        grounded_rule = std_rule.substitute(substitution)
        result = action_registry.call_rule_actions(grounded_rule)
        expect(result).to eq(["HUME"])
      end
    end
    context "when rule has multiple actions" do
      it do
        action_registry = described_class.new.tap do |act_reg|
          act_reg.add(:upcase_name, &function_a)
          act_reg.map_rule_to_action(rule, :upcase_name, **{ name: "x" })

          act_reg.add(:sub_name, &function_b)
          act_reg.map_rule_to_action(rule, :sub_name, **{ name: "x" })
        end
        substitution = {
          sentence_factory.build("x_1") => sentence_factory.build("Hume")
        }
        std_rule = rule.standardize_apart(rule, reset_var_count: false)
        grounded_rule = std_rule.substitute(substitution)
        result = action_registry.call_rule_actions(grounded_rule)
        expect(result).to eq(%w[HUME Leibniz])
      end
    end
  end

  def sentence_factory
    RuleRover::FirstOrderLogic::Sentences::Factory
  end
end
