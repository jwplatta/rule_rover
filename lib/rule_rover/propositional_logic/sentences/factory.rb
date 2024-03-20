module RuleRover::PropositionalLogic::Sentences
  class Factory
    class << self
      def build(*args)
        unless wff?(*args)
          raise RuleRover::SentenceNotWellFormedError.new("Sentence is not a well-formed formula: #{args.inspect}")
        end

        if args.size == 1 and args.first.is_a? String
          Atomic.new(args.first)
        elsif args.size == 2
          Negation.new(build(*args[1]))
        elsif args.size >= 3 and args.size <= 5
          connective_index = args.find_index do |elm|
            [:and, :or, :then, :iff].include?(elm)
          end
          connective = args[connective_index]
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
            raise SentenceNotWellFormedError.new("Sentence is not a well-formed formula: #{args.inspect}")
          end
        else
          raise SentenceNotWellFormedError.new("Sentence is not a well-formed formula: #{args.inspect}")
        end
      end

      def remove_outer_array(sentence)
        if sentence.is_a? Array and sentence.first.is_a? Array
          sentence.first
        else
          sentence
        end
      end

      def wff?(*sentence)
        if sentence.length == 1 and sentence[0].is_a? String
          true
        elsif sentence.length == 2 and sentence[0] == :not
          sentence[1].is_a? String or wff?(*sentence[1])
        elsif sentence.size == 3 and RuleRover::CONNECTIVES.include?(sentence[1])
          wff?(*sentence[0]) and wff?(*sentence[2])
        elsif sentence.size == 4 and RuleRover::CONNECTIVES.include?(sentence[1])
          wff?(*sentence[0]) and wff?(*sentence[2..])
        elsif sentence.size >= 2 and sentence[0] == :not and RuleRover::CONNECTIVES.include?(sentence[2])
          wff?(*sentence[0..1]) and wff?(*sentence[3..])
        else
          false
        end
      end
    end
  end
end