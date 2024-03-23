module RuleRover::PropositionalLogic::Sentences
  class Sentence
    def initialize(left, right)
      @left = left
      @right = right
    end

    attr_reader :left, :right

    def evaluate(model)
      raise NotImplementedError
    end

    def eliminate_biconditionals
      self.class.new(
        left.eliminate_biconditionals,
        right.eliminate_biconditionals
      )
    end

    def eliminate_conditionals
      self.class.new(
        left.eliminate_conditionals,
        right.eliminate_conditionals
      )
    end

    def elim_double_negations
      self.class.new(
        left.elim_double_negations,
        right.elim_double_negations
      )
    end

    def de_morgans_laws
      self.class.new(
        left.de_morgans_laws,
        right.de_morgans_laws
      )
    end

    def distribute
      self.class.new(
        left.distribute,
        right.distribute
      )
    end

    def symbols
      left.symbols.merge(right.symbols)
    end

    def atoms
      left.atoms + right.atoms
    end

    def is_atomic?
      false
    end

    def is_definite?
      false
    end

    def is_positive?
      false
    end

    def to_cnf
      self.eliminate_biconditionals.then do |sent|
        sent.eliminate_conditionals
      end.then do |prev_sent|
        changing = true
        until not changing
          updated = prev_sent.elim_double_negations.then do |sent|
            sent.de_morgans_laws
          end

          if updated.to_s == prev_sent.to_s
            changing = false
          else
            prev_sent = updated
          end
        end
        updated
      end.then do |prev_sent|
        changing = true
        until not changing
          updated = prev_sent.distribute
          if updated.to_s == prev_sent.to_s
            changing = false
          else
            prev_sent = updated
          end
        end
        prev_sent
      end
    end

    def to_s
      raise NotImplementedError
    end

    def ==(other)
      to_s == other.to_s
    end

    def eql?(other)
      self == other
    end

    def hash
      to_s.hash
    end
  end
end