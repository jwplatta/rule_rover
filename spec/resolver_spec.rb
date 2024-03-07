require 'spec_helper'

describe RuleRover do
  xdescribe '.pl_resolve' do
    it do
      prop_kb = RuleRover::PropositionalKB.build("A ⊃ B", "B ⊃ C", "A")
      result =  RuleRover::Resolution.entail?(prop_kb, "C")
      expect(result).to be true
    end
    it do
      a = RuleRover::Statements::Statement.new("A")
      b = RuleRover::Statements::Statement.new("B")
      c = RuleRover::Statements::Statement.new("C")

      prop_kb = RuleRover::PropositionalKB.new
      prop_kb.assert(a.or(b.not).⊃(c))
      prop_kb.assert(a)

      result = RuleRover.pl_resolve(knowledge_base: prop_kb, statement: c)

      expect(result).to be true
    end
    it do
      a = RuleRover::Statements::Statement.new("A")
      b = RuleRover::Statements::Statement.new("B")
      c = RuleRover::Statements::Statement.new("C")

      prop_kb = RuleRover::PropositionalKB.new
      prop_kb.assert(b.and(a))
      prop_kb.assert(b.⊃(c))

      result = RuleRover.pl_resolve(knowledge_base: prop_kb, statement: c.not)

      expect(result).to be false
    end
  end
end
