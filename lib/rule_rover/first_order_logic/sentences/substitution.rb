module RuleRover::FirstOrderLogic::Sentences
  module Substitution
    def substitution
      @substitution ||= {}
    end

    def substitution=(subst)
      @substitution = subst
    end

    def substitute(subst = {})
      return self unless subst

      subst.each do |key, _|
        raise ArgumentError, "Substitution key must be a Variable" unless key.is_a? Variable
      end

      if is_a? Variable
        subst[self] || self
      elsif is_a? ConstantSymbol
        self
      elsif is_a? PredicateSymbol
        PredicateSymbol.new(
          name: name,
          subjects: subjects.map { |term| term.substitute(subst) },
          objects: objects.map { |term| term.substitute(subst) }
        ).tap do |new_sent|
          new_sent.substitution = subst
          new_sent.standardization = standardization if standardization
        end
      elsif is_a? FunctionSymbol
        FunctionSymbol.new(
          name: name,
          args: args.map { |term| term.substitute(subst) }
        ).tap do |new_sent|
          new_sent.substitution = subst
          new_sent.standardization = standardization if standardization
        end
      elsif [Conjunction, Disjunction, Conditional, Biconditional, Equals].include? self.class
        self.class.new(
          left.substitute(subst),
          right.substitute(subst)
        ).tap do |new_sent|
          new_sent.substitution = subst
          new_sent.standardization = standardization if standardization
        end
      elsif is_a? Negation
        Negation.new(sentence.substitute(subst)).tap do |new_negation|
          new_negation.substitution = subst
        end.tap do |new_sent|
          new_sent.substitution = subst
          new_sent.standardization = standardization if standardization
        end
      elsif [ExistentialQuantifier, UniversalQuantifier].include? self.class
        self.class.new(
          vars.map { |var| var.substitute(subst) },
          sentence.substitute(subst)
        ).tap do |new_sent|
          new_sent.substitution = subst
          new_sent.standardization = standardization if standardization
        end
      else
        raise NotImplementedError, "Substitution not implemented for #{self.class}"
      end
    end
  end
end
