module MyKen
  module ModelChecker
    # NOTE: is the statement true for every model
    # in which the knowledge base is true?
    class << self
      def entail?(knowledge_base, statement)
        raise ArgumentError.new("Must be PropositionalKB") unless knowledge_base.is_a? MyKen::PropositionalKB

        MyKen::Statements.to_conjunctive_normal_form(statement).then do |stmt_cnf|
          literals(knowledge_base.to_statement.and(stmt_cnf))
        end.then do |literals|
          enumerate_truth_tables(knowledge_base, statement, literals, {})
        end
      end

      def enumerate_truth_tables(knowledge_base, statement, literals, model)
        if literals.empty?
          true_in_model?(statement, model) if true_in_model?(knowledge_base.to_statement, model)
          true
        else
          literal, literals = literals[0], literals[1..]

          return (enumerate_truth_tables(knowledge_base, statement, literals, model.merge({literal.identifier => false})) and \
            enumerate_truth_tables(knowledge_base, statement, literals, model.merge({literal.identifier => true})))
        end
      end

      def true_in_model?(statement, model)
        # NOTE: assume statements is a list of conjuncts in CNF
        if statement.statements.empty?
          model[statement.identifier]
        elsif statement.identifier == "not"
          not(true_in_model?(statement.statements[0], model))
        elsif statement.identifier == "or"
          true_in_model?(statement.statements[0], model) or true_in_model?(statement.statements[1], model)
        elsif statement.identifier == "and"
          true_in_model?(statement.statements[0], model) and true_in_model?(statement.statements[1], model)
        else
          raise StandardError.new("Unrecognized identifier")
        end
      end

      def literals(statement)
        # NOTE: assume statements is a list of conjuncts in CNF
        if statement.statements.empty?
          [statement]
        elsif statement.identifier == "not"
          literals(statement.statements[0])
        else
          [literals(statement.statements[0]), literals(statement.statements[1])].flatten.uniq
        end
      end

      ##############################
      ### OG Model Checker Below ###
      ##############################

      def run(knowledge_base, statement)
        all_models = truth_table(knowledge_base.cardinality)
        check_all(knowledge_base, statement, all_models)
      end

      def check_all_recursive(knowledge_base, statement)
        raise StandardError.new('Not implemented')
      end

      def check_all(knowledge_base, statement, all_models)
        all_models.each do |truth_values|
          knowledge_base.update_model(*truth_values)
          return false if knowledge_base.value && not(statement.value)
        end

        true
      end

      def truth_table(num_atomic_statements)
        row_cnt = 2 ** num_atomic_statements
        row_multiple = 1
        truth_table = []

        while (row_cnt / 2) > 0
          row_cnt = (row_cnt / 2)
          truth_table << (([true] * row_cnt + [false] * row_cnt) * row_multiple).flatten

          num_atomic_statements -= 1
          row_multiple = row_multiple * 2
        end

        truth_table.transpose
      end
    end
  end
end
