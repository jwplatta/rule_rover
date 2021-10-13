module MyKen
  module Statements
    class Proposition
      attr_reader :operator, :terms, :symbol

      class << self
        def parse(prop_string)
          tokens = prop_string.scan(/[A-Z]|not|and|or|≡|⊃|\(|\)/)
          idx = 0

          begin
            idx = 0 if idx >= tokens.size
            next_token = tokens[idx]
            # binding.pry
            if !next_token.is_a? Proposition and next_token.match?(/[A-Z]/)
              if tokens[idx-1] == "(" and tokens[idx+1] == ")"
                tokens[idx-1..idx+1] = Proposition.new(next_token)
              else
                tokens[idx] = Proposition.new(next_token)
              end
            elsif tokens[idx-1].is_a? Proposition and tokens[idx+1].is_a? Proposition and next_token.match?(/and|or|≡|⊃/)
              if tokens.size == 3
                tokens[idx-1..idx+1] = Proposition.new(next_token, tokens[idx-1], tokens[idx+1])
              else
                tokens[idx-2..idx+2] = Proposition.new(next_token, tokens[idx-1], tokens[idx+1])
              end
            elsif tokens[idx+1].is_a? Proposition and next_token.match?(/not/)
              if tokens[idx-1] == "(" and tokens[idx+2] == ")"
                tokens[idx-1..idx+2] = Proposition.new(next_token, tokens[idx+1])
              else
                tokens[idx..idx+1] = Proposition.new(next_token, tokens[idx+1])
              end
            else
              idx += 1
            end
          end while tokens.size > 1

          tokens.first
        end
      end

      def initialize(*symbols)
        @symbol, @operator, @terms = validate(symbols[0], symbols[1..])
      end

      def not
        Proposition.new("not", self)
      end

      def and(other)
        Proposition.new("and", self, other)
      end

      def or(other)
        Proposition.new("or", self, other)
      end

      def ⊃(other)
        Proposition.new("⊃", self, other)
      end

      def ≡(other)
        Proposition.new("≡", self, other)
      end

      def symbol
        raise StandardError.new("Not an atomic statement: #{self.to_s}") if terms.any?
        @symbol
      end

      def to_cnf
        ToCNF.transform(self)
      end

      def to_conjuncts
        # NOTE: assumes CNF
        if operator != "and"
          [self]
        else
          terms.map { |term| term.conjunction? ? term.to_conjuncts : term }.flatten
        end
      end

      def to_disjuncts
        # NOTE: assumes CNF
        if operator != "or"
          [self]
        else
          terms.map { |term| term.disjunction? ? term.to_disjuncts : term }.flatten
        end
      end

      def left
        terms[0]
      end

      def right
        terms[1]
      end

      def conditional?
        operator == "⊃"
      end

      def biconditional?
        operator == "≡"
      end

      def disjunction?
        operator == "or"
      end

      def conjunction?
        operator == "and"
      end

      def negation?
        operator == "not"
      end

      def complex?
        !terms.empty?
      end

      def atomic?
        terms.empty?
      end

      def ==(other)
        return false unless other.is_a? Proposition

        if self.atomic? and other.atomic?
          self.to_s == other.to_s
        elsif self.operator == other.operator
          if self.negation?
            self.left == other.left
          else
            cnf_cjs = self.to_cnf.to_conjuncts.map(&:to_s).sort
            other_cjs = other.to_cnf.to_conjuncts.map(&:to_s).sort
            cnf_cjs == other_cjs
            # diff = cnf_cjs.select { |cjs| !other_cjs.include? cjs }
            # diff += other_cjs.select { |cjs| !cnf_cjs.include? cjs }
            # diff.empty?
          end
        else
          false
        end
      end

      def to_s
        if operator and terms.size == 2
          terms.map(&:to_s).join(" #{operator} ").then { |stmts| "(#{stmts})" }
        elsif operator and terms
          first_term = terms[0].to_s

          if first_term[0] == "(" and first_term[-1] == ")"
            "#{operator}#{first_term}"
          else
            "#{operator}(#{first_term})"
          end
        else
          symbol
        end
      end

      private

      def validate(operator, statements)
        stmt_cnt = statements.size

        if stmt_cnt == 0 and operator[/[A-Z]/]
          [operator, nil, []]
        elsif (stmt_cnt == 1 and operator[/^not$/]) or (stmt_cnt == 2 and operator[/⊃|≡|^or$|^and$/])
          terms = statements.map do |stmt|
            if stmt.is_a? Proposition
              stmt
            elsif stmt[/[A-Z]/]
              Proposition.new(stmt)
            else
              raise NotWellFormedFormula.new(operator, statements)
            end
          end

          [nil, operator, terms]
        else
          raise NotWellFormedFormula.new(operator, statements)
        end
      end
    end
  end
end
