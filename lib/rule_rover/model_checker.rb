module RuleRover
  class UnassignedLiteral < StandardError
    def initialize(literal)
      super("Literal not assigned in model: #{literal}")
    end
  end

  class ModelChecker
    # NOTE: is the statement true for every model
    # in which the knowledge base is true?
    class << self
      def entail?(kb, query)
        raise ArgumentError.new("Must be PropositionalKB") unless kb.is_a? RuleRover::PropositionalKB

        query = RuleRover::Statements::Proposition.parse(query).to_cnf if query.is_a? String

        self.new(kb, query).entail?
      end
    end

    def initialize(kb=nil, query=nil)
      @kb = kb
      @query = query
    end

    attr_reader :kb, :query

    def entail?
      enumerate_truth_tables(kb, query, literals(kb.to_statement.and(query)), {})
    end

    def true_in_model?(prop, model)
      # NOTE: assume statements is a list of conjuncts in CNF
      if prop.negation?
        not(true_in_model?(prop.left, model))
      elsif prop.disjunction?
        true_in_model?(prop.left, model) or true_in_model?(prop.right, model)
      elsif prop.conjunction?
        true_in_model?(prop.left, model) and true_in_model?(prop.right, model)
      else
        raise RuleRover::UnassignedLiteral.new(prop) unless model.keys.include? prop.symbol
        model[prop.symbol]
      end
    end

    def literals(prop, literals=[])
      # NOTE: assume statements is a list of conjuncts in CNF
      if prop.terms.empty?
        literals << prop.symbol
      elsif prop.negation?
        literals(prop.left, literals)
      else
        (literals(prop.left, literals) + literals(prop.right, literals)).uniq
      end
    end

    private

    def enumerate_truth_tables(kb, query, literals, model)
      if literals.empty?
        if true_in_model?(kb.to_statement, model)
          true_in_model?(query, model)
        else
          true
        end
      else
        literal, literals = literals[0], literals[1..]
        return (enumerate_truth_tables(kb, query, literals, model.merge({literal => false})) and \
          enumerate_truth_tables(kb, query, literals, model.merge({literal => true})))
      end
    end
  end
end
