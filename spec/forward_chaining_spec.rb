require 'spec_helper'

describe RuleRover::ForwardChaining do
  context 'conjunction as antecedent' do
    it do
      predicate_kb = RuleRover::PredicateKB.new
      predicate_x = RuleRover::Statements::Predicate.new(identifier: "Pancakes", assignments: { "a" => "AA" })
      predicate_y = RuleRover::Statements::Predicate.new(identifier: "Flour", assignments: { "b" => "BB" })
      predicate_z = RuleRover::Statements::Predicate.new(identifier: "Eggs", assignments: { "c" => "CC" })

      predicate_kb.assert(predicate_y.and(predicate_z).⊃(predicate_x))
      predicate_kb.assert(predicate_y)
      predicate_kb.assert(predicate_z)

      RuleRover::ForwardChaining.entail?(predicate_kb, predicate_x)

      expect(predicate_kb.clauses.map(&:to_s)).to include("Pancakes(AA)")
    end
  end
  context 'multiple applications of modus ponens' do
    it do
      predicate_kb = RuleRover::PredicateKB.new
      predicate_a = RuleRover::Statements::Predicate.new(identifier: "A", assignments: { "a" => "AA" })
      predicate_b = RuleRover::Statements::Predicate.new(identifier: "B", assignments: { "b" => "BB" })
      predicate_c = RuleRover::Statements::Predicate.new(identifier: "C", assignments: { "c" => "CC" })
      predicate_d = RuleRover::Statements::Predicate.new(identifier: "D", assignments: { "d" => "DD" })

      predicate_kb.assert(predicate_a.⊃(predicate_b))
      predicate_kb.assert(predicate_b.⊃(predicate_c))
      predicate_kb.assert(predicate_c.and(predicate_a).⊃(predicate_d))
      predicate_kb.assert(predicate_a)

      RuleRover::ForwardChaining.entail?(predicate_kb, predicate_d)

      expect(predicate_kb.clauses.map(&:to_s)).to include("D(DD)")
    end
  end
end
