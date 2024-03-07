module RuleRover
  module Statements
    class ToCNF
      class << self
        def transform(proposition)
          self.new(proposition).transform
        end
      end

      def initialize(proposition)
        unless proposition.is_a? Proposition
          raise ArgumentError.new("Must be an instance of #{Proposition.class}")
        end

        @proposition = proposition
      end

      attr_reader :proposition

      def transform
        elim_bicond(proposition.clone).then do |prop|
          elim_cond(prop)
        end.then do |prop|
          move_negation_to_literals(prop)
        end.then do |prop|
          distribute(prop)
        end.then do |prop|
          sort_terms(prop)
        end
      end

      def sort_terms(prop)
        if prop.disjunction?
          prop.to_disjuncts.sort do |x, y|
            x_s = x.negation? ? x.left.to_s : x.to_s
            y_s = y.negation? ? y.left.to_s : y.to_s
            x_s <=> y_s
          end.then do |sorted_djs|
            sorted_djs[1..].reduce(sorted_djs[0]) do |prop, clause|
              prop.or(clause)
            end
          end
        elsif prop.conjunction?
          left = if prop.left.atomic?
            prop.left
          else
            sort_terms(prop.left)
          end

          right = if prop.right.atomic?
            prop.right
          else
            sort_terms(prop.right)
          end

          left.and(right)
        else
          prop
        end
      end

      def sort_disjuncts(disjunction)
        disjunction
      end

      private

      def elim_bicond(prop)
        if prop.terms.empty?
          prop
        elsif prop.terms.size == 1
          Proposition.new(prop.operator, elim_bicond(prop.left))
        elsif prop.biconditional?
          left, right = elim_bicond(prop.left), elim_bicond(prop.right)
          new_left, new_right = Proposition.new("⊃", left, right), Proposition.new("⊃", right, left)
          Proposition.new("and", new_left, new_right)
        else
          Proposition.new(prop.operator, elim_bicond(prop.left), elim_bicond(prop.right))
        end
      end

      def elim_cond(prop)
        if prop.terms.empty?
          prop
        elsif prop.terms.size == 1
          Proposition.new(prop.operator, elim_cond(prop.left))
        elsif prop.conditional?
          new_left = Proposition.new("not", elim_cond(prop.left))
          new_right = elim_cond(prop.right)
          Proposition.new("or", new_left, new_right)
        else
          Proposition.new(prop.operator, elim_cond(prop.left), elim_cond(prop.right))
        end
      end

      def move_negation_to_literals(prop)
        if prop.terms.empty?
          prop
        elsif prop.operator == "not"
          neg_term = prop.left

          if neg_term.atomic?
            prop
          elsif neg_term.operator == "not"
            move_negation_to_literals(neg_term.left)
          elsif neg_term.operator == "or"
            Proposition.new("and", neg_term.left.not, neg_term.right.not)
              .then { |stmt| move_negation_to_literals(stmt) }
          elsif neg_term.operator == "and"
            Proposition.new("or", neg_term.left.not, neg_term.right.not)
              .then { |stmt| move_negation_to_literals(stmt) }
          end
        else
          Proposition.new(
            prop.operator,
            move_negation_to_literals(prop.left),
            move_negation_to_literals(prop.right)
          )
        end
      end

      def distribute(prop)
        if distribute?(prop)
          or_over_and(prop).then { |new_prop| distribute(new_prop) }
        else
          prop
        end
      end

      def or_over_and(prop)
        # NOTE: (alpha or (beta and gamma)) :: ((alpha or beta) and (alpha or gamma))
        # (A or (B and C))
        #
        # (A or ((B and C) or D))
        # (A or ((B or D) and (C or D)))
        # ((A or (B or D)) and (A or (C or D)))
        #
        # ((B and C) or (A and D))
        # ((B and C) or A) and ((B and C) or D)
        if prop.atomic? or prop.operator == "not"
          prop
        elsif prop.disjunction? and prop.left.conjunction?
          left = Proposition.new("or", prop.left.left, prop.right)
          right = Proposition.new("or", prop.left.right, prop.right)
          Proposition.new("and", left, right)
        elsif prop.disjunction? and prop.right.conjunction?
          left = Proposition.new("or", prop.left, prop.right.left)
          right = Proposition.new("or", prop.left, prop.right.right)
          Proposition.new("and", left, right)
        else
          Proposition.new(
            prop.operator,
            or_over_and(prop.left),
            or_over_and(prop.right)
          )
        end
      end

      def distribute?(prop)
        if prop.atomic?
          false
        elsif prop.negation?
          distribute?(prop.left)
        elsif prop.conjunction?
          distribute?(prop.left) or distribute?(prop.right)
        elsif prop.disjunction?
          prop.left.conjunction? or prop.right.conjunction? or distribute?(prop.left) or distribute?(prop.right)
        end
      end
    end
  end
end
