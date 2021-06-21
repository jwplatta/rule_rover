module MyKen
  module ConjunctiveNormalForm
    class Converter
      class << self
        def run(statement)
          stmt = eliminate_biconditionals(statement).then do |stmt|
            eliminate_conditionals(stmt)
          end.then do |stmt|
            move_negation_to_literals(stmt)
          end.then do |stmt|
            eliminate_double_negation(stmt)
          end.then do |stmt|
            distribute_twice(stmt)
          end

          stmt
        end

        def eliminate_biconditionals(statement)
          return statement if statement.atomic?

          statement_x = if statement.statement_x.atomic?
            statement.statement_x
          else
            eliminate_biconditionals(statement.statement_x)
          end

          statement_y = if statement.operator == "not" or statement.statement_y.atomic?
            statement.statement_y
          else
            eliminate_biconditionals(statement.statement_y)
          end

          if statement.operator == "≡"
            MyKen::Statements::ComplexStatement.new(
              MyKen::Statements::ComplexStatement.new(statement_x, statement_y, "⊃"),
              MyKen::Statements::ComplexStatement.new(statement_y, statement_x, "⊃"),
              "and"
            )
          else
            MyKen::Statements::ComplexStatement.new(
              statement_x,
              statement_y,
              statement.operator
            )
          end
        end

        def eliminate_conditionals(statement)
          return statement if statement.atomic?

          statement_x = if statement.statement_x.atomic?
            statement.statement_x
          else
            eliminate_conditionals(statement.statement_x)
          end

          statement_y = if statement.operator == "not" or statement.statement_y.atomic?
            statement.statement_y
          else
            eliminate_conditionals(statement.statement_y)
          end

          if statement.operator == "⊃"
            MyKen::Statements::ComplexStatement.new(
              MyKen::Statements::ComplexStatement.new(statement_x, nil, "not"),
              statement_y,
              "or"
            )
          else
            MyKen::Statements::ComplexStatement.new(
              statement_x,
              statement_y,
              statement.operator
            )
          end
        end

        def move_negation_to_literals(statement)
          # NOTE: apply DeMorgan's Rule
          return statement if statement.nil? or statement.atomic?

          new_statement = if statement.operator == "not" and statement.statement_x.operator == "or"
            MyKen::Statements::ComplexStatement.new(
              MyKen::Statements::ComplexStatement.new(statement.statement_x.statement_x, nil, "not"),
              MyKen::Statements::ComplexStatement.new(statement.statement_x.statement_y, nil, "not"),
              "and"
            )
          elsif statement.operator == "not" and statement.statement_x.operator == "and"
            MyKen::Statements::ComplexStatement.new(
              MyKen::Statements::ComplexStatement.new(statement.statement_x.statement_x, nil, "not"),
              MyKen::Statements::ComplexStatement.new(statement.statement_x.statement_y, nil, "not"),
              "or"
            )
          else
            statement
          end

          MyKen::Statements::ComplexStatement.new(
            move_negation_to_literals(new_statement.statement_x),
            move_negation_to_literals(new_statement.statement_y),
            new_statement.operator
          )

        end

        def eliminate_double_negation(statement)
          return statement if statement.nil? or statement.atomic?

          # NOTE: oi va voi! This line sets the
          # current statement equal to the nested non-negated
          # statement thereby removing the double negation.
          if statement.operator == "not" and statement.statement_x.operator == "not" and statement.statement_x.statement_x.atomic?
            statement.statement_x.statement_x
          else
            MyKen::Statements::ComplexStatement.new(
              eliminate_double_negation(statement.statement_x),
              eliminate_double_negation(statement.statement_y),
              statement.operator
            )
          end
        end

        def distribute_twice(statement)
          # NOTE: hack, please fix. Changes to the statement after the first
          # distribution might make successive distributions necessary.
          # The algorithm needs to keep distributing until the ORs have
          # been completely distributed over the ANDs
          distribute(statement).then do |stmt|
            distribute(stmt)
          end
        end

        def distribute(statement)
          return statement if statement.nil? or statement.atomic?

          distributed_statement = if statement.operator == "or" and statement.statement_x.operator == "and"
            MyKen::Statements::ComplexStatement.new(
              MyKen::Statements::ComplexStatement.new(statement.statement_x.statement_x, statement.statement_y, "or"),
              MyKen::Statements::ComplexStatement.new(statement.statement_x.statement_y, statement.statement_y, "or"),
              "and"
            )
          elsif statement.operator == "or" and statement.statement_y.operator == "and"
            MyKen::Statements::ComplexStatement.new(
              MyKen::Statements::ComplexStatement.new(statement.statement_x, statement.statement_y.statement_x, "or"),
              MyKen::Statements::ComplexStatement.new(statement.statement_x, statement.statement_y.statement_y, "or"),
              "and"
            )
          else
            statement
          end

          statement_x = if distributed_statement.statement_x.atomic?
            distributed_statement.statement_x
          else
            distribute(distributed_statement.statement_x)
          end

          statement_y = if distributed_statement.statement_y.nil? or distributed_statement.statement_y.atomic?
            distributed_statement.statement_y
          else
            distribute(distributed_statement.statement_y)
          end

          MyKen::Statements::ComplexStatement.new(
            statement_x,
            statement_y,
            distributed_statement.operator
          )
        end
      end
    end
  end
end
