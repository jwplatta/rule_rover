module MyKen
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
      raise ArgumentError.new("Model is dimension is too large.") if args.size != cardinality

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

  class PropositionalKB
    attr_reader :clauses

    def initialize()
      @clauses = []
    end

    def to_statement
      clauses[1..].reduce(clauses[0]) { |stmt, cls| stmt.and(cls) }
    end

    def assert(statement)
      new_clauses = MyKen::Statements.to_conjunctive_normal_form(statement).then do |stmt|
        MyKen::Statements.conjuncts(stmt)
      end.reject do |cls|
        clauses.include? cls
      end

      @clauses = (clauses << new_clauses).flatten
    end

    def deny(statement)
      conjuncts = MyKen::Statements.to_conjunctive_normal_form(statement).then do |stmt|
        MyKen::Statements.conjuncts(stmt)
      end

      @clauses = clauses.reject { |clause| conjuncts.include? clause }
    end

    def query(statement)
      MyKen::Statements.to_conjunctive_normal_form(statement).then do |stmt|
        MyKen::Statements.conjuncts(stmt)
      end.reduce(true) do |result, cls|
        clauses.include? cls and result
      end
    end
  end

  class PredicateKB
    attr_reader :clauses, :variables, :predicates

    def initialize
      @clauses = []
      @variables = []
      @predicates = []
    end

    def to_statement
    end

    def assert(statement)
    end

    def deny(statement)
    end

    def query(statement)
    end
  end
end
