module RuleRover::PropositionalLogic::Algorithms
  class Resolution < LogicAlgorithmBase
    class EmptyClause; end

    def entail?
      sentence_factory.build(:not, query).then do |query|
        kb.sentences + [query]
      end.then do |all_sentences|
        all_sentences.map do |sentence|
          sentence.to_cnf
        end
      end.then do |all_sent_cnf|
        find_clauses(all_sent_cnf)
      end.then do |clauses|
        resolve(clauses)
      end
    end

    private

    def find_clauses(sentences)
      # NOTE: assumes that the sentences are in CNF
      clauses = []
      while not sentences.empty?
        sent = sentences.shift

        if sent.is_a? conjunction
          sentences << sent.left
          sentences << sent.right
        elsif not clauses.include? sent
          clauses << sent
        end
      end
      clauses
    end

    def resolve(clauses)
      new_clauses = []
      clauses.combination(2).to_a.each do |cls_a, cls_b|
        complements = first_complements(cls_a, cls_b)
        if complements.empty?
          next
        else
          resolve_clauses(cls_a.atoms, cls_b.atoms, *complements).then do |new_clause|
            if new_clause.is_a? EmptyClause
              return true
            elsif not new_clauses.include? new_clause
              new_clauses << new_clause
            end
          end
        end
      end

      if new_clauses.all? { |new_cls| clauses.include? new_cls }
        return false
      else
        resolve(clauses + new_clauses.select { |new_cls| not clauses.include? new_cls })
      end
    end

    def resolve_clauses(cls_a_atoms, cls_b_atoms, comp_a, comp_b)
      cls_a_atoms.delete_at(cls_a_atoms.index(comp_a))
      cls_b_atoms.delete_at(cls_b_atoms.index(comp_b))

      if cls_a_atoms.empty? and cls_b_atoms.empty?
        EmptyClause.new
      else
        Set.new(cls_a_atoms + cls_b_atoms).to_a.then do |new_atoms|
          if new_atoms.size == 1
            new_atoms.first
          else
            left, right = new_atoms.shift(2)

            new_clause = disjunction.new(left, right)
            while not new_atoms.empty?
              new_clause = disjunction.new(new_clause, new_atoms.shift)
            end
            new_clause
          end
        end
      end
    end

    def first_complements(clause_a, clause_b)
      clause_a.atoms.product(clause_b.atoms).find do |atomic_a, atomic_b|
        complements?(atomic_a, atomic_b)
      end || []
    end

    def complements?(a, b)
      (a.is_a?(negation) and a.sentence == b) or (b.is_a?(negation) and b.sentence == a)
    end

    def negation
      RuleRover::PropositionalLogic::Sentences::Negation
    end

    def conjunction
      RuleRover::PropositionalLogic::Sentences::Conjunction
    end

    def disjunction
      RuleRover::PropositionalLogic::Sentences::Disjunction
    end
  end
end