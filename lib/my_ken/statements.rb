module MyKen
  module Statements
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
