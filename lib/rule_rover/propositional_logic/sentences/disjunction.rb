module RuleRover::PropositionalLogic::Sentences
  class NotDefiniteClause < StandardError; end

  class Disjunction < Sentence
    def evaluate(model)
      left.evaluate(model) or right.evaluate(model)
    end

    def distribute
      if left.is_a? Conjunction and right.is_a? Conjunction
        Conjunction.new(
          Disjunction.new(left.left, right.distribute),
          Disjunction.new(left.right, right.distribute)
        )
      elsif left.is_a? Conjunction
        Conjunction.new(
          Disjunction.new(left.left, right),
          Disjunction.new(left.right, right)
        )
      elsif right.is_a? Conjunction
        Conjunction.new(
          Disjunction.new(left, right.left),
          Disjunction.new(left, right.right)
        )
      else
        self
      end
    end

    def premise_and_conclusion
      raise NotDefiniteClause.new unless is_definite?

      sents = [left, right]

      conclusion = nil
      premise = []

      while sents.any?
        sent = sents.shift

        if sent.is_positive?
          conclusion = sent
        elsif sent.is_atomic?
          premise << sent
        elsif (sent.left.is_a? Disjunction or sent.left.is_atomic?) \
          and (sent.right.is_a? Disjunction or sent.right.is_atomic?)
          sents << sent.left
          sents << sent.right
        end
      end

      [premise, conclusion]
    end

    def is_definite?
      sents = [left, right]
      post_cnt = 0

      while sents.any?
        sent = sents.shift

        if sent.is_positive?
          post_cnt += 1
        elsif sent.is_atomic?
          next
        elsif (sent.left.is_a? Disjunction or sent.left.is_atomic?) \
          and (sent.right.is_a? Disjunction or sent.right.is_atomic?)
          sents << sent.left
          sents << sent.right
        end

        return false if post_cnt > 1
      end

      post_cnt == 1
    end

    def is_horn?
      sents = [left, right]
      post_cnt = 0
      while sents.any?
        sent = sents.shift

        if sent.is_positive?
          post_cnt += 1
        elsif sent.is_atomic?
          next
        elsif (sent.left.is_a? Disjunction or sent.left.is_atomic?) \
          and (sent.right.is_a? Disjunction or sent.right.is_atomic?)
          sents << sent.left
          sents << sent.right
        end

        return false if post_cnt > 1
      end
      true
    end

    def clauses
      if left.atomic? or left.is_a? Negation
        [self]
      else
        left.clauses + right.clauses
      end
    end

    def to_s
      "[#{left} :or #{right}]"
    end
  end
end
