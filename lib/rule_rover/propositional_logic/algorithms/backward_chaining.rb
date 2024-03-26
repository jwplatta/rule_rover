module RuleRover::PropositionalLogic::Algorithms
  class BackwardChaining < LogicAlgorithmBase
    def entail?
      # NOTE: assume all sentences in kb are clauses
      kb_copy = kb.dup
      kb.sentences << query
      kb_copy.symbols.merge(query.symbols)

      satisfy?(kb.sentences, kb.symbols, {})
    end

    def satisfy?(clauses, symbols, model)
      # TODO: #evaluate_partial

      if clauses.all? { |cls| cls.evaluate(model) }
        true
      elsif symbols.all? { |sym| model.keys.include? sym } and clauses.any? { |cls| not cls.evaluate(model) }
        # NOTE: not exactly correct - should evaluate all clauses that have all their literals assigned
        false
      else
        pure_symbol, pure_symbol_value = find_pure_symbol(symbols, clauses, model)

        if pure_symbol
          symbols.delete(pure_symbol)
          satisfy?(clauses, symbols, model.merge({pure_symbol => pure_symbol_value}))
        else
          unassigned_symbol, unassigned_symbol_value = find_unit_clause(clauses, model)

          if unassigned_symbol
            symbols.delete(unassigned_symbol)
            satisfy?(clauses, symbols, model.merge({unassigned_symbol => unassigned_symbol_value}))
          else
            next_symbol = symbols.first
            rest_symbols = symbols.to_a[1..]

            satisfy?(clauses, rest_symbols, model.merge({next_symbol => true })) or \
              satisfy?(clauses, rest_symbols, model.merge({next_symbol => false}))
          end
        end
      end
    end

    def find_pure_symbol(symbols, clauses, model)
      # NOTE: a pure symbol is a symbol that always has the same sign in all clauses
      # NOTE: ignore clauses whose symbols are all in the model
      filtered_clauses = clauses.select do |clause|
        clause.symbols.any? { |symbol| not model.keys.include? symbol }
      end

      # NOTE: ignore true clauses
      filtered_clauses = filtered_clauses.select do |clause|
        clause  unless clause.evaluate(model)
      end

      all_atoms = clauses.map { |cls| cls.atoms.to_a }.flatten
      candidate_atoms = filtered_clauses.map { |cls| cls.atoms.to_a }.flatten

      candidate_atoms.each do |atom|
        complement = if atom.is_a? RuleRover::PropositionalLogic::Sentences::Negation
          sentence_factory.build(atom.symbol)
        else
          sentence_factory.build(:not, atom.symbol)
        end

        if all_atoms.find { |atom| atom == complement }
          next
        else
          return [atom.symbol, atom.is_a?(RuleRover::PropositionalLogic::Sentences::Atomic)]
        end
      end

      [nil, false]
    end

    def find_unit_clause(clauses, model)
      unassigned_atoms = clauses.map do |cls|
        is_unit?(cls, model)
      end

      first_unassigned_atom = if unassigned_atoms.any?
        unassigned_atoms.first
      end

      if first_unassigned_atom.is_a? RuleRover::PropositionalLogic::Sentences::Atomic
        [first_unassigned_atom.symbol, true]
      elsif first_unassigned_atom.is_a? RuleRover::PropositionalLogic::Sentences::Negation
        [first_unassigned_atom.symbol, false]
      else
        [nil, nil]
      end
    end

    def is_unit?(clause, model)
      atoms_with_unassigned_symbols = clause.atoms.select do |atom|
        model_includes_symbol = model.keys.include? atom.symbol
        return nil if model_includes_symbol and atom.evaluate(model)
        not model_includes_symbol
      end

      if atoms_with_unassigned_symbols.size == 1
        atoms_with_unassigned_symbols.first
      end
    end
  end
end