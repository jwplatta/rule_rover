module RuleRover::FirstOrderLogic::Sentences
  module Substitution
    def substitute(mapping={})
      # TODO: need to check that mapping uses Variable objects as keys
      return self unless mapping

      if is_a? Variable
        mapping[self] || self
      elsif is_a? ConstantSymbol
        self
      elsif is_a? PredicateSymbol
        PredicateSymbol.new(
          name: name,
          subjects: subjects.map { |term| term.substitute(mapping) },
          objects: objects.map { |term| term.substitute(mapping) }
        )
      elsif is_a? FunctionSymbol
        FunctionSymbol.new(
          name: name,
          args: args.map { |term| term.substitute(mapping) }
        )
      elsif [Conjunction, Disjunction, Conditional, Biconditional, Equals].include? self.class
        self.class.new(left.substitute(mapping), right.substitute(mapping))
      elsif is_a? Negation
        Negation.new(sentence.substitute(mapping))
      elsif [ExistentialQuantifier, UniversalQuantifier].include? self.class
        self.class.new(
          vars.map { |var| var.substitute(mapping) },
          sentence.substitute(mapping)
        )
      else
        raise NotImplementedError, "Substitution not implemented for #{self.class}"
      end
    end
  end
end
