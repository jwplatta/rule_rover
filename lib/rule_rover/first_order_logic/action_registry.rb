require_relative "./sentences/unification"

module RuleRover::FirstOrderLogic
  class DuplicateActionExists < ArgumentError; end
  class SentenceIsNotARule < ArgumentError; end
  class ActionDoesNotExist < ArgumentError; end
  class SentenceNotAbstract < ArgumentError; end

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
      subst = {}

      key = rule_action_map.keys.find do |key|
        subst = unify(rule, key)
        subst
      end

      if key
        rule.standardization = key.standardization
        rule.substitution = subst
        rule_action_map.fetch(key, [])
      else
        []
      end
    end

    def map_rule_to_action(rule, name, **params)
      raise ActionDoesNotExist.new(name) unless exists?(name)
      # TODO: explicitly check if the sentence is a definite clause
      # Might depend on the knowledge base to do this.

      raise SentenceIsNotARule.new unless rule.is_a? RuleRover::FirstOrderLogic::Sentences::Conditional

      # NOTE: does it matter if the sentence is abstract?
      raise SentenceNotAbstract.new unless rule.lifted?

      dup_rule = rule.dup

      rule_action_map[dup_rule] ||= []
      rule_action_map[dup_rule] << { name: name, params: params }
    end

    def call_rule_actions(rule)
      return unless rule.grounded?

      # NOTE: Uses the mapping stored on the rule from standardize_apart
      # to map the rule's variables to the action's parameters

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
      return unless exists?(name)

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
