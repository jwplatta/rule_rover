module RuleRover::FirstOrderLogic::Sentences
  class Factory
    class << self
      def build(*args)
        puts "args: #{args.inspect}"
        if args.size == 1 and ConstantSymbol.valid_name?(args.first)
          ConstantSymbol.new(args.first)
        elsif PredicateSymbol.valid_name?(*args)
          PredicateSymbol.new(*args)
        elsif FunctionSymbol.valid_name?(*args)
          FunctionSymbol.new(*args)
        else
          raise SentenceNotWellFormedError.new(args.inspect)
        end
      end
    end
  end
end