module RuleRover
  module Statements
    VALID_CONSTANTS = /[A-Z]/
    VALID_OPERATORS = /⊃|≡|not|^or$|^and$/
    VALID_VARIABLES = /a-z/

    class NotWellFormedFormula < StandardError
      def initialize(logic_symbol="", statements=[])
        super("Not a well formed formula\n\tlogic_symbol: #{logic_symbol}\n\tstatements: #{statements}")
      end
    end

    def self.conjuncts(statement)
      # NOTE: assumes the top-level operator of the statement is a conjunction
      if statement.identifier == "and"
        [
          conjuncts(statement.statements[0]),
          conjuncts(statement.statements[1])
        ].flatten
      else
        [statement]
      end
    end

    def self.disjuncts(statement)
      # NOTE: assumes the top-level operator of the statement is a disjunction
      if statement.identifier == "or"
        [
          disjuncts(statement.statements[0]),
          disjuncts(statement.statements[1])
        ].flatten
      else
        [statement]
      end
    end

    def self.to_conjunctive_normal_form(statement)
      raise ArgumentError.new("statement is not an instance of #{Statement.class}") unless statement.is_a? Statement

      eliminate_biconditionals(statement).then do |stmt|
        eliminate_conditionals(stmt)
      end.then do |stmt|
        move_negation_to_literals(stmt)
      end.then do |stmt|
        distribute(stmt)
      end
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
          Statement.new("⊃", cond_x, cond_y),
          Statement.new("⊃", cond_y, cond_x)
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

      def predicate?
        self.class == Predicate
      end

      def substitute(assignment)
        Statement.new(
          identifier,
          *statements.map { |stmt| stmt.substitute(assignment) }.flatten
        )
      end

      def variables
        # NOTE: you're starting to use this pattern a lot: init array -> loop to get vals -> uniq.
        # Is there a better way to do this in ruby?
        statements.map do |stmt|
          stmt.variables
        end.flatten.uniq
      end

      def eql?(other)
        self.==(other)
      end

      def ==(other)
        if other.statements.empty? and statements.empty?
          self.to_s == other.to_s
        elsif other.identifier == identifier
          if identifier == "not"
            statements[0] == other.statements[0]
          else
            self_cnf = RuleRover::Statements.to_conjunctive_normal_form(self)
            other_cnf = RuleRover::Statements.to_conjunctive_normal_form(other)

            self_groups_disjuncts = RuleRover::Statements.conjuncts(self_cnf).map do |cnjncts|
              RuleRover::Statements.disjuncts(cnjncts)
            end.map { |grp| grp.sort { |a, b| a.to_s <=> b.to_s } }

            other_groups_disjuncts = RuleRover::Statements.conjuncts(other_cnf).map do |cnjncts|
              RuleRover::Statements.disjuncts(cnjncts)
            end.map { |grp| grp.sort { |a, b| a.to_s <=> b.to_s } }

            (other_groups_disjuncts.flatten - self_groups_disjuncts.flatten).empty?
          end
        else
          false
        end
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

    def self.variable?(symbol)
      return false unless symbol.is_a? String

      not(symbol[/^[a-z]$/].nil?)
    end

    def self.constant?(symbol)
      not(symbol[/^[A-Z][A-Za-z]*/].nil?)
    end

    def self.definite_clause?(clause)
      clause_cnf = to_conjunctive_normal_form(clause)

      return true if clause_cnf.statements.empty?
      return false if clause_cnf.identifier != "or"

      sub_stmts = [clause_cnf]
      cnt_pos = 0

      while sub_stmts.any? and cnt_pos < 2
        stmt = sub_stmts.pop

        lhs = stmt.statements[0]
        rhs = stmt.statements[1]

        cnt_pos += 1 if lhs.statements.empty?
        cnt_pos += 1 if rhs.statements.empty?

        sub_stmts << lhs if lhs.identifier != "not" and lhs.statements.any?
        sub_stmts << rhs if rhs.identifier != "not" and rhs.statements.any?
      end

      cnt_pos == 1
    end

    def self.standardize_apart(*statements)
      # NOTE: assumes statements are Predicates
      variable_symbols = ('a'..'z').to_a
      var_cnt = 0

      statements.map do |stmt|
        updated_assignments = stmt.assignments.map do |k, v|
          index = var_cnt % variable_symbols.size
          mult = (var_cnt / variable_symbols.size) + 1
          var_cnt += 1

          [variable_symbols[index] * mult, v]
        end.to_h

        Predicate.new(identifier: stmt.identifier, assignments: updated_assignments)
      end
    end

    def self.unify(expression_x, expression_y, assignment)
      # REVIEW: assumes expressions x and y do not have conflicting variable names.
      # TODO: implement .standardize_apart
      # REVIEW: check before .unify
      #   1. Do the expressions have the same predicates?
      #   2. Are the predicates in the correct order, e.g. the algo will not work for "A(x) and B(y)" and "B(z) and A(w)"
      #   3. Have the variables been standardized apart?

      if assignment.nil?
        {}
      elsif expression_x.is_a? Predicate and expression_y.is_a? Predicate
        new_assignment = assignment.merge(
          expression_x.assignments.filter { |_, v| !(v.nil?) },
          expression_y.assignments.filter { |_, v| !(v.nil?) }
        )

        unify(
          expression_x.variables,
          expression_y.variables,
          unify(
            expression_x.identifier,
            expression_y.identifier,
            new_assignment
          )
        )
      elsif variable? expression_x
        if assignment.keys.include? expression_x
          unify(assignment[expression_x], expression_y, assignment)
        elsif assignment.keys.include? expression_y
          unify(expression_x, assignment[expression_y], assignment)
        elsif occurs?(expression_x, expression_y, assignment)
          nil
        else
          # NOTE: substitute for complex terms
          assignment.select { |k, v| v.is_a? ComplexTerm and v.variable == expression_x }.each do |_, v|
            v.substitute({ expression_x => expression_y })
          end
          assignment.merge({ expression_x => expression_y })
        end
      elsif expression_x == expression_y
        assignment
      elsif variable? expression_y
        if assignment.keys.include? expression_y
          unify(assignment[expression_y], expression_x, assignment)
        elsif assignment.keys.include? expression_x
          unify(expression_y, assignment[expression_x], assignment)
        elsif occurs?(expression_y, expression_x, assignment)
          nil
        else
          # NOTE: substitute for complex terms
          assignment.select { |k, v| v.is_a? ComplexTerm and v.variable == expression_y }.each do |_, v|
            v.substitute({ expression_y => expression_x })
          end
          assignment.merge({ expression_y => expression_x })
        end
      elsif expression_x.is_a? Statement and expression_y.is_a? Statement
        unify(
          expression_x.statements,
          expression_y.statements,
          unify(expression_x.identifier, expression_y.identifier, assignment)
        )
      elsif expression_x.is_a? Array and expression_y.is_a? Array
        # NOTE: assumes statements are in the correct order, i.e. the
        # implementation is not smart enough associativity and recognize "A(x) and B(y)"
        # is logically equivalent to "B(y) and A(x)".
        first_unified = unify(expression_x.pop, expression_y.pop, assignment)

        if first_unified.nil? or first_unified.empty?
          # NOTE: stop if unable to unify the first expressions
          {}
        else
          # NOTE: keep unifying the rest of the complex statement
          unify(
            expression_x,
            expression_y,
            first_unified
          )
        end
      end
    end

    def self.occurs?(var, expression, assignments)
      return false unless variable?(var)

      if expression.is_a? Predicate
        expression.variables.include? var
      elsif expression.is_a? Statement
        if expression.statements.empty?
          var == assignments.select { |var, const| const == expression.identifier }.keys[0]
        elsif expression.identifier == "not"
          occurs?(var, expression.statements[0], assignments)
        else
          (occurs?(var, expression.statements[0], assignments) or \
            occurs?(var, expression.statements[1], assignments))
        end
      else
        false
      end
    end

    def self.substitute(statement, assignments)
      if statement.is_a? Predicate or statement.is_a? ComplexTerm
        statement.substitute(assignments)
      elsif statement.identifier == "not"
        Statement.new(
          "not",
          substitute(statement.statements[0], assignments)
        )
      elsif statement.statements.count == 2
        Statement.new(
          statement.identifier,
          substitute(statement.statements[0], assignments),
          substitute(statement.statements[1], assignments)
        )
      else
        statement
      end
    end

    class ComplexTerm < Statement
      attr_reader :assignments

      def initialize(identifier:, assignments: {"x" => nil})
        @identifier = identifier #complex_term[/(\w+)/, 1]
        @assignments = assignments
        @statements = []
      end

      def variable
        assignments.keys.first
      end

      def substitute(new_assignments)
        ComplexTerm.new(
          identifier: self.identifier,
          assignments: new_assignments.select { |k, v| variable == k }
        )
      end

      def ==(other)
        other.is_a? ComplexTerm and \
        to_s == other.to_s
      end

      def to_s
        var, val = assignments.first

        if val.nil?
          "#{identifier}[#{var}]"
        else
          "#{identifier}[#{val}]"
        end
      end
    end

    # REVIEW: why try to parse strings inside the predicate class
    # Should do this elsewhere and keep teh Predicate class focused on
    # just beign a Predicate.
    # NOTE: the order of the variables matter
    class Predicate < Statement
      attr_reader :assignments

      def initialize(identifier:, assignments: {})
        @identifier = identifier
        @assignments = assignments
        @statements = []

        # @var_cnt = 0
        # predicate_statement = extract_complex_terms(predicate_statement)

        # unless predicate_statement[/^[A-Z][A-Za-z]*\(([A-Za-z_]*|[[A-Za-z_]*, ])*\)/].to_s == predicate_statement
        #   raise ArgumentError.new("Invalid predicate")
        # end

        # @identifier = predicate_statement[/(\w+)/, 1]
        # vars_and_consts = predicate_statement[/\((.*?)\)/, 1].gsub(" ", "").split(",")
        # build_var_assignment(vars_and_consts)
      end

      def substitute(new_assignments)
        Predicate.new(
          identifier: self.identifier,
          assignments: assignments.merge(new_assignments.select { |k, v| variables.include? k })
        )
      end

      def variables
        assignments.keys
      end

      def constants
        assignments.values.reject { |val| val.nil? }
      end

      def arity
        assignments.keys.count
      end

      def ==(other)
        other.is_a? Predicate and \
        other.identifier == identifier and \
        other.assignments == assignments
      end

      def to_s
        assignments.map { |k, v| v.nil? ? k : v }.then do |symbols|
          "#{identifier}(#{symbols.join(", ")})"
        end
      end

      private

      # def validate_assignment(assignment)
      #   assignment.each do |k, v|
      #     if v.is_a? ComplexTerm and not(assignment.keys.include? v.assignments.first[0])
      #       raise StandardError.new("Variables of ComplexTerms must exist in the Predicate variables")
      #     end
      #   end
      # end

      def complex_terms_with_var(var)
        assignments.select do |k, v|
          v.is_a? ComplexTerm and v.assignments.has_key? var
        end
      end

      # attr_reader :var_cnt
      # REVIEW: move these methods to some sort of Predicate parser class
      def extract_complex_terms(predicate_statement)
        complex_terms = predicate_statement.scan(/[A-Za-z]*\[[A-Za-z]*\]/)

        return predicate_statement if complex_terms.empty?

        complex_terms.each_with_index.map do |ct, idx|
          @assignments[next_variable] = ComplexTerm.new(ct)
          predicate_statement.gsub!(ct, "_")
        end
      end

      def build_var_assignment(vars_and_consts)
        vars_and_consts.each do |symbol|
          if variable?(symbol)
            @assignments[next_variable] = nil
          elsif constant?(symbol)
            @assignments[next_variable] = symbol
          else
            raise StandardError.new("unrecognized symbol")
          end
        end
      end

      def next_variable
        # REVIEW: not great, but works
        variable_symbols = ('a'..'z').to_a
        index = var_cnt % variable_symbols.size
        mult = (var_cnt / variable_symbols.size) + 1
        @var_cnt += 1
        variable_symbols[index] * mult
      end

      def variable?(symbol)
        RuleRover::Statements.variable?(symbol)
      end

      def constant?(symbol)
        RuleRover::Statements.constant?(symbol)
      end
    end

    class NullStatement
      def nil?
        true
      end

      def identifier; end

      def predicate?
        false
      end

      def substitute(_)
        NullStatement.new
      end

      def variables
        []
      end

      def operator
        nil
      end

      def value
        nil
      end

      def statements
        []
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

    ####################################
    ### REMOVE: OG Statement structs ###
    ####################################

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
