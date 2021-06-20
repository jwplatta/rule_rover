module MyKen
  module ConjunctiveNormalForm
    class Converter
      class << self
        def run(statement)
          if statement.atomic? or \
            (statement.operator == "not" and statement.statement_x.atomic?) or \
            (["or", "and"].include? statement.operator and statement.statement_x.atomic? and statement.statement_y.atomic?)
            return statement
          end

          new_statement = MyKen::Statements::ComplexStatement.new

          # STEP: eliminate all the conditionals and biconditionals
          statement_x = run(statement.statement_x)
          statement_y = run(statement.statement_y) unless statement.operator == "not"

          if statement.operator == "⊃"
            new_statement.operator = "or"
            new_statement.statement_x = run(MyKen::Statements::ComplexStatement.new(statement_x, nil, "not"))
            new_statement.statement_y = statement_y
          elsif statement.operator == "≡"
            new_statement.operator = "and"
            new_statement.statement_x = run(MyKen::Statements::ComplexStatement.new(statement_x, statement_y, "⊃"))
            new_statement.statement_y = run(MyKen::Statements::ComplexStatement.new(statement_y, statement_x, "⊃"))
          elsif statement.operator == "not"
            # STEP 2: remove negatives of ComplexStatements

            if statement_x.operator == "not"
              # NOTE: oi va voi! This line sets the
              # current statement equal to the nested non-negated
              # statement thereby removing the double negation.
              new_statement = statement_x.statement_x
            elsif statement_x.operator == "or"
              new_statement.operator = "and"
              new_statement.statement_x = run(MyKen::Statements::ComplexStatement.new(statement_x.statement_x, nil, "not"))
              new_statement.statement_y = run(MyKen::Statements::ComplexStatement.new(statement_x.statement_y, nil, "not"))
            elsif statement_x.operator == "and"
              new_statement.operator = "or"
              new_statement.statement_x = run(MyKen::Statements::ComplexStatement.new(statement_x.statement_x, nil, "not"))
              new_statement.statement_y = run(MyKen::Statements::ComplexStatement.new(statement_x.statement_y, nil, "not"))
            end
          else
            new_statement.operator = statement.operator
            new_statement.statement_x = statement_x
            new_statement.statement_y = statement_y
          end

          # STEP: apply the Distributivity Law
          # REVIEW: oi va voi again! This can consolidated into a single method.
          if !new_statement.atomic? and new_statement.statement_x.atomic? and !new_statement.statement_y&.atomic?
            if new_statement.statement_y.operator == "or" and new_statement.operator == "and"
              distributed_statement = MyKen::Statements::ComplexStatement.new
              distributed_statement.operator = "or"
              distributed_statement.statement_x = MyKen::Statements::ComplexStatement.new(new_statement.statement_y.statement_x, new_statement.statement_x, "and")
              distributed_statement.statement_y = MyKen::Statements::ComplexStatement.new(new_statement.statement_y.statement_y, new_statement.statement_x, "and")
              new_statement = distributed_statement
            elsif new_statement.statement_y.operator == "and" and new_statement.operator == "or"
              distributed_statement = MyKen::Statements::ComplexStatement.new
              distributed_statement.operator = "and"
              distributed_statement.statement_x = MyKen::Statements::ComplexStatement.new(new_statement.statement_y.statement_x, new_statement.statement_x, "or")
              distributed_statement.statement_y = MyKen::Statements::ComplexStatement.new(new_statement.statement_y.statement_x, new_statement.statement_x, "or")
              new_statement = distributed_statement
            end
          elsif !new_statement.atomic? and new_statement.statement_y&.atomic? and !new_statement.statement_x.atomic?
            if new_statement.statement_x.operator == "or" and new_statement.operator == "and"
              distributed_statement = MyKen::Statements::ComplexStatement.new
              distributed_statement.operator = "or"
              distributed_statement.statement_x = MyKen::Statements::ComplexStatement.new(new_statement.statement_x.statement_x, new_statement.statement_y, "and")
              distributed_statement.statement_y = MyKen::Statements::ComplexStatement.new(new_statement.statement_x.statement_y, new_statement.statement_y, "and")
              new_statement = distributed_statement
            elsif new_statement.statement_x.operator == "and" and new_statement.operator == "or"
              distributed_statement = MyKen::Statements::ComplexStatement.new
              distributed_statement.operator = "and"
              distributed_statement.statement_x = MyKen::Statements::ComplexStatement.new(new_statement.statement_x.statement_x, new_statement.statement_y, "or")
              distributed_statement.statement_y = MyKen::Statements::ComplexStatement.new(new_statement.statement_x.statement_y, new_statement.statement_y, "or")
              new_statement = distributed_statement
            end
          end

          new_statement
        end
      end
    end
  end
end
