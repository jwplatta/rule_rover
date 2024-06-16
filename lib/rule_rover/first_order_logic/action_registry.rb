require_relative  './sentences/unification.rb'

module RuleRover::FirstOrderLogic
  class DuplicateActionExists < StandardError; end
  class SentenceIsNotARule < StandardError; end
  class ActionDoesNotExist < StandardError; end

  class ActionRegistry
    include Sentences::Unification

    def initialize(kb: nil, actions: {}, rule_action_map: {})
      @kb = kb
      @actions = actions
      @rule_action_map = rule_action_map
    end

    attr_reader :kb, :actions, :rule_action_map

    def add(name, &block)
      raise DuplicateActionExists.new("Action already exists: #{name}") if exists?(name)

      @actions[name] = new_action(
        name,
        *block.parameters.map(&:last),
        &block
      )

      @actions[name]
    end

    def remove(name)
      @actions.delete(name)
    end

    def rule_actions(rule)
      key = rule_action_map.keys.find { |key| unify(key, rule).any? }
      rule_action_map.fetch(key, [])
    end

    def map_rule_to_action(rule, name, **params)
      # TODO: check that the rule is lifted
      raise ActionDoesNotExist.new(name) unless exists?(name)
      unless rule.is_a? RuleRover::FirstOrderLogic::Sentences::Conditional
        raise SentenceIsNotARule.new
      end

      rule_action_map[rule] ||= []
      rule_action_map[rule] << { name: name, params: params }
    end

    def call_rule_actions(rule)
      # return unless rule_action_map.key?(rule)
      return unless rule.grounded?
      # NOTE: will need to use the mapping stored on the rule from standardize_apart
      # in order to map the rule's variables to the action's parameters

      rule_actions(rule).map do |action|
        params = action[:params].each_with_object({}) do |item, params_hash|
          param_name, val = item
          sent_key = RuleRover::FirstOrderLogic::Sentences::Factory.build(val)

          # NOTE: the action gets created with the variable name provided by the user.
          # The knowledge base standardizes apart the variables of each sentence added to it.
          # So the mapping stored on the rule maintans the original variable name and the standardized variable name.
          params_hash[param_name] = rule.standardization.fetch(sent_key, sent_key).then do |standardized_var|
            rule.substitution.fetch(standardized_var, nil)
          end.value
        end

        call(action[:name], **params)
      end
    end

    def call(name, **params)
      raise ActionDoesNotExist.new(name) unless exists?(name)
      action = find(name)
      action.func.call(**params)
    end

    def exists?(name)
      find(name) ? true : false
    end

    def find(name)
      actions.fetch(name, nil)
    end

    private

    def new_action(name, *param_names, &block)
      Action.new(block, name: name, param_names: param_names)
    end
  end
end
