module RuleRover
  class KnowledgeBase
    def initialize(&block)
      @clauses = [] # TODO:
      @statements = []
      @atomic_statements = []
      yield self
    end

    attr_reader :statements, :atomic_statements

    def add_fact(statement)
      raise StandardError.new('Statement must be assigned a truth value.') if statement.value.nil?

      @atomic_statements << statement if statement.is_a? Statements::AtomicStatement
      @statements << statement
    end

    def cardinality
      atomic_statements.size
    end

    def update_model(*args)
      raise ArgumentError.new("Model dimension is too large.") if args.size != cardinality

      @atomic_statements.zip(args).each do |as, val|
        as.value = val
      end
    end

    def value
      statements.map(&:value).reduce(&:'&')
    end

    def to_s
      statements.map do |stmt|
        stmt.to_s
      end.join("\n")
    end
  end

  class PredicateKB
    # REVIEW: so far #assert, #deny, #to_statement are nearly identical
    # to the methods in the PropositionalKB
    attr_reader :clauses, :variables, :predicates

    def initialize
      @clauses = []
      @variables = []
      @predicates = []
    end

    def constants
      statements = []
      constants = []
      statements += clauses

      while statements.any?
        stmt = statements.pop

        if stmt.predicate?
          constants += stmt.constants
        else
          statements += stmt.statements
        end
      end

      constants.uniq
    end

    def assert(statement)
      # new_clauses = RuleRover::Statements.to_conjunctive_normal_form(statement).then do |stmt|
      #   RuleRover::Statements.conjuncts(stmt)
      # end.reject do |cls|
      #   clauses.include? cls
      # end

      # new_clauses.each do |new_cls|
      #   raise ArgumentError.new("Can only add definite clauses to the knowledge base.") unless definite_clause?(new_cls)
      # end

      # @clauses = (@clauses << new_clauses).flatten
      raise ArgumentError.new("Can only add definite clauses to the knowledge base.") unless definite_clause?(statement)

      @clauses << statement unless clauses.include? statement
    end

    def deny(statement)
      conjuncts = RuleRover::Statements.to_conjunctive_normal_form(statement).then do |stmt|
        RuleRover::Statements.conjuncts(stmt)
      end

      @clauses = clauses.reject { |clause| conjuncts.include? clause }
    end

    def to_statement
      clauses[1..].reduce(clauses[0]) { |stmt, cls| stmt.and(cls) }
    end

    private

    def standardize_apart
      @clauses = RuleRover::Statements.standardize_apart(*clauses)
    end

    def definite_clause?(clause)
      RuleRover::Statements.definite_clause?(clause)
    end
  end
end
