module RuleRover::FirstOrderLogic::Sentences
  class Factory
    class << self
      def build(*args)

        if args.size == 1 and ConstantSymbol.valid_name?(args.first)
          ConstantSymbol.new(args.first)
        elsif args.size == 1 and Variable.valid_name?(args.first)
          Variable.new(args.first)
        elsif PredicateSymbol.valid_name?(*args)
          name_index = args.find_index { |elm| elm.is_a? Symbol and /^[a-z]/.match?(elm) }

          PredicateSymbol.new(
            name: args[name_index],
            subjects: args[0...name_index].map { |var| build(var) },
            objects: args[(name_index + 1)...].map { |var| build(var) }
          )
        elsif FunctionSymbol.valid_name?(*args)
          FunctionSymbol.new(
            name: args.find { |elm| elm.is_a? Symbol and /^@/.match?(elm) },
            args: args.select { |elm| not(/^@/.match?(elm)) }.map { |var| build(var) }
          )
        elsif args.size == 2 and args.first == :not
          Negation.new(build(*args[1]))
        elsif args.size == 3 and args.first == :all
          vars = if args[1].is_a? Array
            args[1].map { |var| build(var) }
          else
            [build(*args[1])]
          end

          UniversalQuantifier.new(
            vars,
            build(*args[2])
          )
        elsif args.size == 3 and args.first == :some
          vars = if args[1].is_a? Array
            args[1].map { |var| build(var) }
          else
            [build(*args[1])]
          end

          ExistentialQuantifier.new(
            vars,
            build(*args[2])
          )
        elsif args[1] == :equals and valid_term_name?(*args[0]) and valid_term_name?(*args[2])
          Equals.new(
            build(*args[0]),
            build(*args[2])
          )
        else
          connective = find_connective(*args)
          if connective
            connective_index = args.index(connective)
            left = remove_outer_array(args[0...connective_index])
            right = remove_outer_array(args[connective_index+1..])

            build_connective(connective, left, right)
          else
            raise RuleRover::SentenceNotWellFormedError.new(args.inspect)
          end
        end
      end

      def build_connective(connective, left, right)
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
      end

      def valid_term_name?(*args)
        Variable.valid_name?(args.first) or \
        ConstantSymbol.valid_name?(args.first) or \
        # NOTE: technically, predicates are not terms
        PredicateSymbol.valid_name?(*args) or \
        FunctionSymbol.valid_name?(*args)
      end

      def find_connective(*args)
        args.find { |elm| RuleRover::FirstOrderLogic::CONNECTIVES.include?(elm) }
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