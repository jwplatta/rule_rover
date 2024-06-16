module RuleRover::FirstOrderLogic

  class Action
    def initialize(func, name: nil, param_names: [])
      unless func_parameters = func.parameters.map { |_, param_name| param_name }.sort == param_names.sort
        raise ArgumentError, "Invalid function parameters: #{func_parameters}"
      end

      unless func.parameters.all? { |param_type, _| param_type == :keyreq}
        raise ArgumentError, "Must use keyword parameters in Action function."
      end

      @func = func
      @name = name
      @param_names = param_names
    end

    attr_reader :name, :param_names, :func

    def call(**params)
      raise ArgumentError, "Invalid number of parameters" unless param_names.length == params.length

      param_names.each do |param_name|
        raise ArgumentError, "Missing parameter: #{param_name}" unless params.key?(param_name)
      end

      @func.call(**params)
    end
  end
end
