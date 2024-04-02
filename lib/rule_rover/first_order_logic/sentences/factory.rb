module RuleRover::FirstOrderLogic::Sentences
  class Factory
    class << self
      def build(*args)
        if args.size == 1 and ConstantSymbol.valid_name?(args.first)
          ConstantSymbol.new(args.first)
        elsif PredicateSymbol.valid_name?(*args)
          PredicateSymbol.new(*args)
        elsif FunctionSymbol.valid_name?(*args)
          FunctionSymbol.new(*args)
        elsif args.size == 2
          Negation.new(build(*args[1]))
        elsif find_connective(*args)
          connective = find_connective(*args)
          puts "connective: #{connective}"
          connective_index = args.index(connective)
          left = remove_outer_array(args[0...connective_index])
          right = remove_outer_array(args[connective_index+1..])

          if connective == :and
            Conjunction.new(
              build(*left),
              build(*right)
            )
          elsif connective == :or
            Disjunction.new(
              build(*left),
              build(*right)
            )
          elsif connective == :then
            Conditional.new(
              build(*left),
              build(*right)
            )
          elsif connective == :iff
            Biconditional.new(
              build(*left),
              build(*right)
            )
          else
            raise RuleRover::SentenceNotWellFormedError.new(args.inspect)
          end
        else
          raise RuleRover::SentenceNotWellFormedError.new(args.inspect)
        end
      end

      def find_connective(*args)
        args.find { |elm| RuleRover::CONNECTIVES.include?(elm) }
      end

      def remove_outer_array(sentence)
        if sentence.is_a? Array and sentence.first.is_a? Array
          sentence.first
        else
          sentence
        end
      end
    end
  end
end