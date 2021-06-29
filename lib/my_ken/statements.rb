module MyKen
  module Statements
    VALID_CONSTANTS = /A-Z/
    VALID_OPERATORS = /⊃|≡|not|or$|and$/
    VALID_VARIABLES = /a-z/

    def substitute(); end
    def unify(); end

    def self.to_conjunctive_normal_form(statement)
      raise ArgumentError.new("statement is not an instance of #{Statement.class}") unless statement.is_a? Statement

      # STEP: eliminate biconditionals
      statement = eliminate_biconditionals(statement)
      # STEP: eliminate conditionals
      statement = eliminate_conditionals(statement)
      # STEP: move_negation_to_literals
      statement = move_negation_to_literals(statement)
      # STEP: distribute AND over OR
      distribute(statement)
    end

    def self.eliminate_biconditionals(statement)
      if statement.statements.empty?
        statement
      elsif statement.statements.size == 1
        Statement.new(
          statement.identifier,
          eliminate_biconditionals(statement.statements[0])
        )
      elsif statement.identifier == "≡"
        cond_x = eliminate_biconditionals(statement.statements[0])
        cond_y = eliminate_biconditionals(statement.statements[1])

        Statement.new(
          "and",
          Statement.new(
            "⊃",
            cond_x,
            cond_y
          ),
          Statement.new(
            "⊃",
            cond_y,
            cond_x
          )
        )
      else
        Statement.new(
          statement.identifier,
          eliminate_biconditionals(statement.statements[0]),
          eliminate_biconditionals(statement.statements[1])
        )
      end
    end

    def self.eliminate_conditionals(statement)
      if statement.statements.empty?
        statement
      elsif statement.statements.size == 1
        Statement.new(
          statement.identifier,
          eliminate_conditionals(statement.statements[0])
        )
      elsif statement.identifier == "⊃"
        Statement.new(
          "not",
          eliminate_conditionals(statement.statements[0])
        ).then do |antecedent|
          Statement.new(
            "or",
            antecedent,
            eliminate_conditionals(statement.statements[1])
          )
        end
      else
        Statement.new(
          statement.identifier,
          eliminate_conditionals(statement.statements[0]),
          eliminate_conditionals(statement.statements[1])
        )
      end
    end

    def self.move_negation_to_literals(statement)
      if statement.statements.empty?
        statement
      elsif statement.identifier == "not"
        negated_statement = statement.statements[0]
        if negated_statement.statements.empty?
          statement
        elsif negated_statement.identifier == "not"
          move_negation_to_literals(negated_statement.statements[0])
        elsif negated_statement.identifier == "or"
          Statement.new(
            "and",
            negated_statement.statements[0].not,
            negated_statement.statements[1].not
          ).then { |stmt| move_negation_to_literals(stmt) }
        elsif negated_statement.identifier == "and"
          Statement.new(
            "or",
            negated_statement.statements[0].not,
            negated_statement.statements[1].not
          ).then { |stmt| move_negation_to_literals(stmt) }
        end
      else
        Statement.new(
          statement.identifier,
          move_negation_to_literals(statement.statements[0]),
          move_negation_to_literals(statement.statements[1])
        )
      end
    end

    def self.distribute(statement)
      while distribute_any?(statement)
        statement = and_over_or(statement)
      end

      statement
    end

    def self.and_over_or(statement)
      # NOTE: (alpha or (beta and gamma)) :: ((alpha or beta) and (alpha or gamma))
      # (A or (B and C))
      #
      # (A or ((B and C) or D))
      # (A or ((B or D) and (C or D)))
      # ((A or (B or D)) and (A or (C or D)))
      #
      # ((B and C) or (A and D))
      # ((B and C) or A) and ((B and C) or D)
      if statement.statements.empty? or statement.identifier == "not"
        statement
      elsif statement.identifier == "or" and statement.statements[0].identifier == "and"
        lhs = Statement.new("or", statement.statements[0].statements[0], statement.statements[1])
        rhs = Statement.new("or", statement.statements[0].statements[1], statement.statements[1])
        Statement.new("and", lhs, rhs)
      elsif statement.identifier == "or" and statement.statements[1].identifier == "and"
        lhs = Statement.new("or", statement.statements[0], statement.statements[1].statements[0])
        rhs = Statement.new("or", statement.statements[0], statement.statements[1].statements[1])
        Statement.new("and", lhs, rhs)
      else
        Statement.new(
          statement.identifier,
          and_over_or(statement.statements[0]),
          and_over_or(statement.statements[1])
        )
      end
    end

    def self.distribute_any?(statement)
      if statement.statements.empty?
        false
      elsif statement.identifier == "not"
        distribute_any?(statement.statements[0])
      elsif statement.identifier == "and"
        distribute_any?(statement.statements[0]) or \
        distribute_any?(statement.statements[1])
      elsif statement.identifier == "or"
        statement.statements[0].identifier == "and" or \
        statement.statements[1].identifier == "and" or \
        distribute_any?(statement.statements[0]) or \
        distribute_any?(statement.statements[1])
      end
    end

    class Statement
      attr_reader :identifier, :statements

      def initialize(identifier, *statements)
        raise ArgumentError.new("Not a valid statement") if identifier.match(VALID_OPERATORS) and statements.empty?

        @identifier = identifier
        @statements = statements
      end

      def not
        Statement.new("not", self)
      end

      def and(other)
        Statement.new("and", self, other)
      end

      def or(other)
        Statement.new("or", self, other)
      end

      def ⊃(other)
        Statement.new("⊃", self, other)
      end

      def ≡(other)
        Statement.new("≡", self, other)
      end

      def to_s
        if statements.size > 1
          statements.map(&:to_s).join(" #{identifier} ").then { |stmts| "(#{stmts})" }
        elsif statements.size == 1
          stmt = statements[0].to_s
          if stmt[0] == "(" and stmt[-1] == ")"
            "#{identifier}#{stmt}"
          else
            "#{identifier}(#{stmt})"
          end
        else
          "#{identifier}"
        end
      end
    end

    class NullStatement
      def atomic?
        false
      end

      def clause?
        false
      end

      def nil?
        true
      end

      def operator
        nil
      end

      def value
        nil
      end

      def statement_x
        NullStatement.new
      end

      def statement_y
        NullStatement.new
      end

      def to_s
        "".freeze
      end
    end

    AtomicStatement = Struct.new(:value, :name) do
      def atomic?
        true
      end

      def clause?
        true
      end

      def operator
        nil
      end

      def to_s
        "#{name}: #{value}"
      end
    end

    ComplexStatement = Struct.new(:statement_x, :statement_y, :operator) do
      def clauses
      end

      def clause?
        (statement_x.atomic? and statement_y.atomic? and operator == "or") or \
        (statement_x.atomic? and statement_y.clause? and operator == "or") or \
        (statement_x.clause? and statement_y.atomic? and operator == "or")
      end

      def value
        case operator
        when "or"
          eval("#{statement_x.value} #{operator} #{statement_y.value}")
        when "and"
          eval("#{statement_x.value} #{operator} #{statement_y.value}")
        when "⊃"
          eval("#{statement_x.value}.#{operator} #{statement_y.value}")
        when "≡"
          eval("#{statement_x.value}.#{operator} #{statement_y.value}")
        when "not"
          eval("#{operator} #{statement_x.value}")
        else
          raise ArgumentError.new("Unrecognized logical operator")
        end
      end

      def atomic?
        false
      end

      def to_s
        statement_x_s = if statement_x.is_a? AtomicStatement
          statement_x.name
        else
          statement_x.to_s
        end

        statement_y_s = if statement_y.is_a? AtomicStatement
          statement_y.name
        else
          statement_y.to_s
        end

        if operator == "not"
          "#{operator}(#{statement_x_s})"
        else
          "(#{statement_x_s} #{operator} #{statement_y_s})"
        end
      end

      def build_string(statement)
        raise StandardError.new('Not implemented')
      end
    end
  end
end
