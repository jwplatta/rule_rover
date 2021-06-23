module MyKen
  class Resolver
    def initialize(knowledge_base:, statement:)
      @knowledge_base = knowledge_base
      @statement = statement
      @explored_statements = []
      @not_statement = MyKen::Statements::ComplexStatement.new(statement, nil, "not")
    end

    attr_reader :knowledge_base, :statement, :not_statement

    def resolve
      return false unless statement_in_kb?
      # NOTE: has complimentary literals?
      @explored_statements += parse_clauses(to_conjunctive_normal_form)

      while @explored_statements.any?
        pairs_of_clauses = @explored_statements.combination(2).to_a
        new_clause_cnt = 0
        pairs_of_clauses.each do |clause_one, clause_two|
          resolve_clauses(clause_one, clause_two).then do |clauses|
            return true if clauses == []

            new_clause = join_clauses(clauses.uniq)

            unless @explored_statements.include? new_clause
              new_clause_cnt += 1
              @explored_statements << new_clause
            end
          end
        end

        # NOTE: if not new clauses, then false
        return false if new_clause_cnt == 0
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

    def statement_in_kb?
      frontier = knowledge_base.statements.map(&:clone)

      while frontier.any?
        kb_stmt = frontier.pop

        return true if kb_stmt == statement or MyKen::Statements::ComplexStatement.new(kb_stmt, nil, "not") == statement

        unless kb_stmt.atomic?
          if kb_stmt.operator == "not"
            frontier.append(kb_stmt.statement_x)
          else
            frontier.append(kb_stmt.statement_x)
            frontier.append(kb_stmt.statement_y)
          end
        end
      end

      false
    end

    private

    def cnf_converter
      MyKen::ConjunctiveNormalForm::Converter
    end
  end
end
