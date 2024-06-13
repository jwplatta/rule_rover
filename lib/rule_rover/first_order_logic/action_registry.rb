module RuleRover::FirstOrderLogic
  class ActionRegistry
    def initialize(kb: nil, actions: {}, rule_action_map: {})
      @kb = kb
      @actions = actions
      @rule_action_map = rule_action_map
    end

    attr_reader :kb, :actions, :rule_action_map

    def add(name, *param_names, &block)
      raise ArgumentError.new("Action already exists: #{name}") if @actions[name]

      @actions[name] = new_action(
        name: name,
        param_names: param_names,
        func: block
      )

      @actions[name]
    end

    def remove(name)
      @actions.delete(name)
    end

    def map_rule_to_action(rule, action_name, **params)
      raise ArgumentError.new("Action does not exist: #{action_name}") unless exists?(action_name)
      unless rule.is_a? RuleRover::FirstOrderLogic::Sentences::Conditional
        raise ArgumentError.new("Rule must be a conditional")
      end

      rule_action_map[rule] ||= []
      rule_action_map[rule] << { name: action_name, params: params }
    end

    def call_rule_actions(rule)
      # NOTE: will need to use the mapping stored on the rule from standardize_apart
      # in order to map the rule's variables to the action's parameters
      actions = rule_action_map.fetch(rule, [])
      actions.each do |action|
        call(action.name, **action.params)
      end
    end

    def call(name, **params)
      find(name).call(**params)
      binding.pry
    end

    def exists?(name)
      find(name) ? true : false
    end

    def find(name)
      actions.fetch(name, nil)
    end

    private

    def new_action(name, *param_names, &block)
      Action.new(name: name, param_names: param_names, func: block)
    end
  end
end
