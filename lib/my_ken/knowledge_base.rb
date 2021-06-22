module MyKen
  class KnowledgeBase
    def initialize(&block)
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
end
