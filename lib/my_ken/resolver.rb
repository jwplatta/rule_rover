module MyKen
  class Resolver
    def initialize(knowledge_base:, statement:)
      @knowledge_base = knowledge_base
      @statement = statement
      @not_statement = MyKen::Statements::ComplexStatement.new(statement, nil, "not")
    end

    attr_reader :knowledge_base, :statement, :not_statement

    def resolve
      # NOTE: has complimentary literals?
      clauses = parse_clauses(to_conjunctive_normal_form)

      while clauses.any?
        pairs_of_clauses = clauses.combination(2).to_a
        # for each pair of clauses in clauses do
        # resolvents = resolve(clause_one, clause_two)

        resolvents = pairs_of_clauses.map do |clause_one, clause_two|
          resolve_clauses(clause_one, clause_two).then do |clauses|
            join_clauses(clauses.uniq)
          end
        end

        # NOTE: if resolvents contains the Empty Clause, then true
        return true if resolvents.include? []

        new_clauses = resolvents.flatten.select do |resolvent|
          !clauses.include? resolvent
        end.uniq

        # NOTE: if not new clauses,, then false
        return false if new_clauses.empty?

        clauses += new_clauses
      end
    end

    def join_clauses(clauses)
      raise ArgumentError.new("#join_clauses requires an Array of Statements") unless clauses.is_a? Array

      if clauses.size == 1
        clauses[0]
      elsif clauses.size == 2
        MyKen::Statements::ComplexStatement.new(clauses[0], clauses[1], "or")
      elsif clauses.size > 2
        start = MyKen::Statements::ComplexStatement.new(clauses[0], clauses[1], "or")

        clauses[2..].reduce(start) do |new_stmt, clause|
          MyKen::Statements::ComplexStatement.new(new_stmt, clause, "or")
        end
      else
        []
      end
    end

    def resolve_clauses(clause_one, clause_two)
      clause_one_atomic_stmts = atomic_statements(clause_one)
      clause_two_atomic_stmts = atomic_statements(clause_two)

      complimentary_literals = (clause_one_atomic_stmts + clause_two_atomic_stmts).combination(2).to_a.map do |atomic1, atomic2|
        unit_resolution(atomic1, atomic2)
      end.flatten

      (clause_one_atomic_stmts.select { |cls| !complimentary_literals.include? cls } + clause_two_atomic_stmts.select { |cls| !complimentary_literals.include? cls }).flatten.uniq
    end

    def unit_resolution(clause_one, clause_two)
      # NOTE: assumes clause_one and clause_two are atomic or negation of atomic

      if clause_one.atomic? and clause_two.operator == "not" and (clause_two.statement_x == clause_one)
        [clause_one, clause_two]
      elsif clause_two.atomic? and clause_one.operator == "not" and (clause_one.statement_x == clause_two)
        [clause_one, clause_two]
      else
        []
      end
    end

    def atomic_statements(clause)
      return [clause] if clause.atomic? or clause.operator == "not"

      statements = []
      frontier = []

      frontier << clause.statement_x
      frontier << clause.statement_y

      while frontier.any?
        stmt = frontier.shift

        if stmt.atomic? or stmt.operator == "not"
          statements << stmt
        else
          frontier << stmt.statement_x
          frontier << stmt.statement_y
        end
      end

      statements
    end

    def to_conjunctive_normal_form
      MyKen::Statements::ComplexStatement.new(
        knowledge_base_statement,
        cnf_converter.run(not_statement),
        "and"
      )
    end

    def parse_clauses(statement)
      clauses = []
      frontier = []

      frontier << statement.statement_x
      frontier << statement.statement_y

      while frontier.any?
        stmt = frontier.shift

        if stmt.atomic? or stmt.operator == "or" or stmt.operator == "not"
          clauses << stmt
        else
          frontier << stmt.statement_x
          frontier << stmt.statement_y
        end
      end

      clauses
    end

    def knowledge_base_statement
      knowledge_base.statements.reduce(nil) do |new_statement, kb_statement|
        if new_statement
          kb_stmt_cnf = cnf_converter.run(kb_statement)
          cnf_converter.run(MyKen::Statements::ComplexStatement.new(new_statement, kb_stmt_cnf, "and"))
        else
          cnf_converter.run(kb_statement)
        end
      end
    end

    private

    def cnf_converter
      MyKen::ConjunctiveNormalForm::Converter
    end
  end
end
