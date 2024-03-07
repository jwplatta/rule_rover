require 'spec_helper'

describe RuleRover::ModelChecker do
  describe '#literals' do
    it do
      kb = RuleRover::PropositionalKB.build("(((((A and B) or not(C)) and D) and not(A)) or B)")
      literals = RuleRover::ModelChecker.new.literals(kb.to_statement)
      expect(literals.sort).to eq ["A", "B", "C", "D"]
    end
    it do
      kb = RuleRover::PropositionalKB.build("((C or C) and (C or C))")
      literals = RuleRover::ModelChecker.new(nil, nil).literals(kb.to_statement)
      expect(literals.sort).to eq ["C"]
    end
  end
  describe '#true_in_model?' do
    it 'returns true for atomic proposition' do
      prop = RuleRover::Statements::Proposition.parse("A")
      model = {
        "A" => true
      }

      result = RuleRover::ModelChecker.new.true_in_model?(prop, model)
      expect(result).to be true
    end
    it 'returns false for negated atomic proposition' do
      prop = RuleRover::Statements::Proposition.parse("not(A)")
      model = {
        "A" => true
      }

      result = RuleRover::ModelChecker.new.true_in_model?(prop, model)
      expect(result).to be false
    end
    it 'returns false when one conjunct is false' do
      prop = RuleRover::Statements::Proposition.parse("A and B")
      model = {
        "A" => true,
        "B" => false
      }

      result = RuleRover::ModelChecker.new.true_in_model?(prop, model)
      expect(result).to be false
    end
    it 'returns true when one disjunct is true' do
      model = {
        "A" => true,
        "B" => false
      }
      prop = RuleRover::Statements::Proposition.parse("A or B")

      result = RuleRover::ModelChecker.new.true_in_model?(prop, model)
      expect(result).to be true
    end
    it 'returns true for a long statement' do
      model = {
        "A" => true,
        "B" => false,
        "C" => false,
        "D" => true
      }
      prop = RuleRover::Statements::Proposition.parse("((A or B) and (C or not(D)))")

      result = RuleRover::ModelChecker.new.true_in_model?(prop, model)
      expect(result).to be false
    end
    context 'when the model is missing a literal' do
      it 'raises' do
        model = {
          "A" => true,
          "B" => false,
          "C" => false
        }
        prop = RuleRover::Statements::Proposition.parse("((A or B) and (C or not(D)))")
        expect do
          RuleRover::ModelChecker.new.true_in_model?(prop, model)
        end.to raise_error(RuleRover::UnassignedLiteral)
      end
    end
  end
  describe '.entail?' do
    it do
      prop_kb = RuleRover::PropositionalKB.build("A ⊃ B", "A")
      expect(RuleRover::ModelChecker.entail?(prop_kb, "B")).to be true
    end
    it do
      prop_kb = RuleRover::PropositionalKB.build("A ⊃ B", "not(B)")
      expect(RuleRover::ModelChecker.entail?(prop_kb, "not(A)")).to be true
    end
    it do
      prop_kb = RuleRover::PropositionalKB.build("A ⊃ B", "B ⊃ C", "A")
      expect(RuleRover::ModelChecker.entail?(prop_kb, "C")).to be true
    end
    it do
      prop_kb = RuleRover::PropositionalKB.build("A ⊃ B", "B ⊃ C", "A")
      expect(RuleRover::ModelChecker.entail?(prop_kb, "A ⊃ C")).to be true
    end
    it do
      prop_kb = RuleRover::PropositionalKB.build("A ⊃ B", "B ⊃ C", "not(A)")
      expect(RuleRover::ModelChecker.entail?(prop_kb, "not(A)")).to be true
    end
    it do
      prop_kb = RuleRover::PropositionalKB.build("A ⊃ B", "B ⊃ C", "not(A)")
      expect(RuleRover::ModelChecker.entail?(prop_kb, "X")).to be false
    end
  end
end
