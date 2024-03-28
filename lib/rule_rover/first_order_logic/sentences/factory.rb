module RuleRover::FirstOrderLogic::Sentences
  class Factory
    class << self
      def build(*args)
        if args.size == 1 and ConstantSymbol.valid?(args)
          ConstantSymbol.new(args.first)
        # elsif args.size == 2
        #   FunctionSymbol.new(*args)
        # elsif args.size == 3
        #   PredicateSymbol.new(*args)
        else
          raise SentenceNotWellFormedError.new(args.inspect)
        end
      end
    end
  end
end