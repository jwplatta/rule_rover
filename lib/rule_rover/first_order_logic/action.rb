module RuleRover::FirstOrderLogic
  class ActionRequiresKeywordParameters < ArgumentError; end
  class ActionMissingParameter < ArgumentError; end

  class Action
    def initialize(func, name: nil, param_names: [])
      unless func.parameters.all? { |param_type, _| param_type == :keyreq}
        raise ActionRequiresKeywordParameters.new
      end

      @func = func
      @name = name
      @param_names = param_names
    end

    attr_reader :name, :param_names, :func

    def call(**params)
      param_names.each do |param_name|
        raise ActionMissingParameter.new(param_name) unless params.key?(param_name)
      end

      @func.call(**params)
    end
  end
end
