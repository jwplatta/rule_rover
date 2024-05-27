module RuleRover::FirstOrderLogic::Sentences
  class Conditional < ComplexSentence
    def conditions
      return @conditions if defined? @conditions

      @conditions ||= []
      frontier = [left]
      while frontier.any?
        current = frontier.shift
        if current.is_a? Conjunction
          frontier << left.left
          frontier << left.right
        elsif [PredicateSymbol, Variable, FunctionSymbol, ConstantSymbol].include? current.class
          @conditions << current
        else
          raise RuleRover::FirstOrderLogic::SentenceNotDefiniteClause.new
        end
      end

      @conditions
    end

    def evaluate(model)
      !left.evaluate(model) or right.evaluate(model)
    end

    def eliminate_conditionals
      Disjunction.new(
        Negation.new(left.eliminate_conditionals),
        right.eliminate_conditionals
      )
    end

    def to_s
      "[#{left} :then #{right}]"
    end
  end
end
