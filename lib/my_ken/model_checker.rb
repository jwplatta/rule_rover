module MyKen
  module ModelChecker
    # NOTE: is the statement true for every model
    # in which the knowledge base is true?
    class << self
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
