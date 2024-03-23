module RuleRover::PropositionalLogic::Algorithms
  class ForwardChaining < LogicAlgorithmBase
    def entail?
      count = kb.sentences.each_with_object({}) do |sentence, count|
        unless sentence.is_atomic?
          premises, _ = sentence.premise_and_conclusion
          symbols = Set.new(premises.map { |premise| premise.symbols }.flatten)
          count[sentence] = symbols.size
        end
      end

      agenda = kb.symbols.to_a
      inferred = agenda.each_with_object({}) { |symbol, inferred| inferred[symbol] = false }

      while agenda.any?
        p = sentence_factory.build(agenda.shift)
        return true if p == query

        if inferred[p] == false
          inferred[p] = true

          kb.sentences.each do |clause|
            premise, conclusion = clause.premise_and_conclusion
            if premise.include? p
              count[clause] -= 1

              if count[cluase] == 0
                # NOTE: conclusion is an atomic, so sentence returns
                # a string instead of a Sentence object - not great design
                agenda << conclusion.sentence
              end
            end
          end
        end
      end
      false
    end
  end
end