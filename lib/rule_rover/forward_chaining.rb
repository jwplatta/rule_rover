require 'set'

module RuleRover
  module ForwardChaining
    class << self
      def entail?(knowledge_base, alpha)
        # STEP: does alpha unify with an existing clause?
        knowledge_base.clauses.each do |clause|
          phi = unify(clause, alpha, {})
          return phi if phi.any?
        end

        kb_constants = knowledge_base.constants

        while true
          new_clauses = []

          knowledge_base.clauses.each do |clause|
            antecedent, consequent = parse_definite_clause(clause)

            # STEP: enumerate all substitutions for the antecedent
            vars = antecedent&.map { |conjunct| conjunct.variables }.flatten
            thetas = kb_constants.repeated_permutation(vars.size).map do |constants|
              vars.zip(constants).to_h
            end

            # STEP: loop through the substitutions
            thetas.each do |theta|
              # STEP: if the substitution produces a statement that's in the knowledge base
              # then substitute theta into the consequent
              substituted_conjuncts = antecedent.map { |conjunct| conjunct.substitute(theta) }
              if antecedent.nil? || substituted_conjuncts.all? { |sub_cj| knowledge_base.clauses.include? sub_cj }
                substituted_consequent = consequent.substitute(theta)
                # STEP: if the substituted consequent does not unify
                # with any statement in the knowledge base,
                # then add the statement to the knowledge base
                if (knowledge_base.clauses + new_clauses).all? { |cls| unify(cls, substituted_consequent, {}).empty? }
                  new_clauses.append(substituted_consequent)
                  # STEP: if the new statement unifies with alpha, then return the result
                  phi = unify(substituted_consequent, alpha, {})

                  if phi.any?
                    new_clauses.each { |nc| knowledge_base.assert(nc) }
                    return phi
                  end
                end
              end
            end
          end

          # STEP: if no new clauses, then return failure
          return {} if new_clauses.empty?

          new_clauses.each { |nc| knowledge_base.assert(nc) }
        end

        {}
      end

      # TODO: move to Statements module
      def parse_definite_clause(definite_clause)
        raise ArgumentError.new('Not a definite clause') unless definite_clause?(definite_clause)

        if definite_clause.predicate?
          [[RuleRover::Statements::NullStatement.new], definite_clause]
        else
          # NOTE: assumes definite_clause is in CNF
          # STEP: find the consequent, i.e. the positive predicate
          # STEP: find the antecedent, i.e. disjunction of negative predicates
          # disjs = disjuncts(definite_clause)
          # antecedent = []
          # consequent = nil

          # disjs.each do |disj|
          #   if disj.identifier == "not"
          #     antecedent << disj
          #   else
          #     consequent = disj
          #   end
          # end

          # [antecedent[1..].reduce(antecedent[0]) { |stmt, cls| stmt.or(cls) }, consequent]

          [RuleRover::Statements.conjuncts(definite_clause.statements.first), definite_clause.statements.last]
        end
      end

      def disjuncts(statement)
        RuleRover::Statements.disjuncts(statement)
      end

      def definite_clause?(clause)
        RuleRover::Statements.definite_clause?(clause)
      end

      def unify(expression_x, expression_y, assignment)
        RuleRover::Statements.unify(expression_x, expression_y, assignment)
      end
    end
  end
end
