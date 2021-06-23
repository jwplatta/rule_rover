module MyKen
  class StatementParser
    attr_reader :statement_text

    VALID_SYMBOLS = /or|and|[A-Za-z]|⊃|≡|\(|\)/
    VALID_CONSTANTS = /[A-Za-z]/
    VALID_OPERATORS = /⊃|≡|or|and/

    def self.parse(statement_text)
      self.new(statement_text).run
    end

    def initialize(statement_text)
      @statement_text = validate_statement(statement_text)
    end

    def run
      parse(statement_text)
    end

    def parse(statement_list)
      # remove outer parentheses if any
      statement_list = remove_parentheses(statement_list)

      # return if Atomic
      return MyKen::Statements::AtomicStatement.new(true, statement_list[0]) if statement_list.size == 1

      # handle negations
      if statement_list[0] == "not"
        MyKen::Statements::ComplexStatement.new(parse(statement_list[1..]), nil, statement_list[0])
      else
        # find the outer operator
        # divide the list in statement_x, statement_y and the operator
        # parse(statement_x)
        # parse(statement_y)
        operator_idx = find_outer_operator_idx(statement_list)
        statement_x_list = statement_list[0..(operator_idx-1)]
        statement_y_list = statement_list[(operator_idx+1)..]

        MyKen::Statements::ComplexStatement.new(parse(statement_x_list), parse(statement_y_list), statement_list[operator_idx])
      end
    end

    def validate_statement(statement_text)
      statement_list = statement_text.scan(/\w+|⊃|≡|\(|\)/)

      if statement_list.join('') != statement_text.delete(' ')
        raise ArgumentError.new("Statement contains an invalid symbol: #{statement_text.gsub(VALID_SYMBOLS, '').gsub(' ', '')}")
      end

      statement_list.each_with_index do |item, idx|
        if idx == 0
          next
        elsif idx == (statement_list.size - 1)
          next
        elsif item.match(/\w+/) and !item.match(/[and|or]/)
          before_item = statement_list[idx-1]
          after_item = statement_list[idx+1]

          if before_item.match(/\w+/) and !before_item.match(/and|or/)
            raise ArgumentError.new("Missing connecting operator")
          end
          if after_item.match(/\w+/) and !after_item.match(/and|or/)
            raise ArgumentError.new("Missing connecting operator")
          end
          if before_item.match(VALID_OPERATORS) and after_item.match(VALID_OPERATORS)
            raise ArgumentError.new("An Atomic statement cannot be joined to multiple Atomic statements: #{statement_list[idx-1..idx+1]}")
          end
        end
      end

      raise ArgumentError.new("missing parenthesis") if statement_list.count("(") != statement_list.count(")")

      statement_list.map(&:downcase)
    end

    def remove_parentheses(statement_list)
      if statement_list[0] == "(" and parentheses_match?(statement_list, 0, statement_list.size - 1)
        statement_list[1..-2]
      else
        statement_list
      end
    end

    def parentheses_match?(statement_list, left_idx, right_idx)
      # FIXME: linear search
      p_cnt = 1

      while p_cnt > 0
        left_idx += 1

        if statement_list[left_idx] == "("
          p_cnt += 1
        elsif statement_list[left_idx] == ")"
          p_cnt -= 1
        end
      end

      left_idx == right_idx
    end

    def find_outer_operator_idx(statement_text)
      # NOTE: assumes outer parentheses have been removed
      # pairs_of_parentheses = statement_text.count("(")
      search = true
      forward = true
      forward_idx = 0
      loop_cnt = 0

      while search
        if loop_cnt > 300
          raise StandardError.new("Unable to find outer operator")
        else
          loop_cnt += 1
        end

        if forward
          symbol = statement_text[forward_idx]
          if symbol.match(/⊃|≡|or|and/)
            return forward_idx
          elsif symbol.match(/[A-Za-z]/)
            forward_idx += 1
          elsif symbol == "("
            p_cnt = 1
            # FIXME: linear search
            while p_cnt > 0
              forward_idx += 1

              if statement_text[forward_idx] == "("
                p_cnt += 1
              elsif statement_text[forward_idx] == ")"
                p_cnt -= 1
              end
            end

            forward_idx += 1
          end
        end
      end
    end
  end
end
