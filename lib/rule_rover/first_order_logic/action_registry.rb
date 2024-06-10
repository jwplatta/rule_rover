module RuleRover::FirstOrderLogic
  class ActionRegistry
    def initialize(kb: nil, actions: {})
      @kb = kb
      @actions = actions
    end

    attr_reader :kb, :actions

    def call(name, **params)
      # find(name).call(**params)
      binding.pry
    end

    def find(name)
      actions.fetch(name, {})
    end

    def add(name, *param_names, &block)
      raise ArgumentError.new("Action already exists: #{name}") if @actions[name]

      @actions[name] = Action.new(
        name: name,
        param_names: param_names,
        func: block
      )

      @actions[name]
    end

    # Adds a new action to the registry, overwriting any existing action with the same name.
    def add!
      @actions[name] = new_action
    end

    def remove(name)
      @actions.delete(name)
    end
  end
end
