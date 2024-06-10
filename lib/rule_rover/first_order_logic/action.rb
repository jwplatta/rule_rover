module RuleRover::FirstOrderLogic
  class Action
    def initialize(name: nil, param_names: [], func: nil)
      @name = name
      @param_names = param_names
      @func = func
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
