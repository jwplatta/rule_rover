require 'pry'
require 'set'

module PropositionalLogic
end

class SentenceNotWellFormedError < StandardError
  def initialize(message = "Sentence is not a well-formed formula.")
    super(message)
  end
end

class EmptyClause
end

class Sentence
  def evaluate(model)
    raise NotImplementedError
  end

  def symbols
    Set.new(left.symbols + right.symbols)
  end

  def is_atomic?
    false
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

class Conjunction < Sentence
  def initialize(left, right)
    @left = left
    @right = right
  end

  attr_reader :left, :right, :operator

  def evaluate(model)
    left.evaluate(model) and right.evaluate(model)
  end

  def eliminate_biconditionals
    Conjunction.new(
      left.eliminate_biconditionals,
      right.eliminate_biconditionals
    )
  end

  def eliminate_conditionals
    Conjunction.new(
      left.eliminate_conditionals,
      right.eliminate_conditionals
    )
  end

  def elim_double_negations
    Conjunction.new(
      left.elim_double_negations,
      right.elim_double_negations
    )
  end

  def de_morgans_laws
    Conjunction.new(
      left.de_morgans_laws,
      right.de_morgans_laws
    )
  end

  def distribute
    Conjunction.new(
      left.distribute,
      right.distribute
    )
  end

  def atomics
    left.atomics + right.atomics
  end

  def to_s
    "[#{left} :and #{right}]"
  end
end

class Disjunction < Sentence
  def initialize(left, right)
    @left = left
    @right = right
  end

  attr_reader :left, :right, :operator

  def evaluate(model)
    left.evaluate(model) or right.evaluate(model)
  end

  def eliminate_biconditionals
    Disjunction.new(
      left.eliminate_biconditionals,
      right.eliminate_biconditionals
    )
  end

  def eliminate_conditionals
    Disjunction.new(
      left.eliminate_conditionals,
      right.eliminate_conditionals
    )
  end

  def elim_double_negations
    Disjunction.new(
      left.elim_double_negations,
      right.elim_double_negations
    )
  end

  def de_morgans_laws
    Disjunction.new(
      left.de_morgans_laws,
      right.de_morgans_laws
    )
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

  def clauses
    if left.atomic? or left.is_a? Negation
      [self]
    else
      left.clauses + right.clauses
    end
  end

  def atomics
    left.atomics + right.atomics
  end

  def to_s
    "[#{left} :or #{right}]"
  end
end

class Conditional < Sentence
  def initialize(left, right)
    @left = left
    @right = right
  end

  attr_reader :left, :right, :operator

  def evaluate(model)
    !left.evaluate(model) or right.evaluate(model)
  end

  def eliminate_biconditionals
    Conditional.new(
      @left.eliminate_biconditionals,
      @right.eliminate_biconditionals
    )
  end

  def eliminate_conditionals
    Disjunction.new(
      Negation.new(@left.eliminate_conditionals),
      @right.eliminate_conditionals
    )
  end

  def elim_double_negations
    Conditional.new(
      left.elim_double_negations,
      right.elim_double_negations
    )
  end

  def de_morgans_laws
    Conditional.new(
      left.de_morgans_laws,
      right.de_morgans_laws
    )
  end

  def atomics
    left.atomics + right.atomics
  end

  def to_s
    "[#{left} :then #{right}]"
  end
end

class Biconditional < Sentence
  def initialize(left, right)
    @left = left
    @right = right
  end

  attr_reader :left, :right, :operator

  def evaluate(model)
    left.evaluate(model) == right.evaluate(model)
  end

  def eliminate_biconditionals
    Conjunction.new(
      Conditional.new(left.eliminate_biconditionals, right.eliminate_biconditionals),
      Conditional.new(right.eliminate_biconditionals, left.eliminate_biconditionals)
    )
  end

  def elim_double_negations
    Biconditional.new(
      left.elim_double_negations,
      right.elim_double_negations
    )
  end

  def de_morgans_laws
    Biconditional.new(
      left.de_morgans_laws,
      right.de_morgans_laws
    )
  end

  def atomics
    left.atomics + right.atomics
  end

  def to_s
    "[#{left.to_s} :iff #{right}]"
  end
end

class Negation < Sentence
  def initialize(sentence)
    @sentence = sentence
  end

  attr_reader :sentence, :operator

  def evaluate(model)
    not sentence.evaluate(model)
  end

  def symbols
    Set.new(sentence.symbols)
  end

  def eliminate_biconditionals
    Negation.new(sentence.eliminate_biconditionals)
  end

  def eliminate_conditionals
    Negation.new(sentence.eliminate_conditionals)
  end

  def distribute
    self
  end

  def elim_double_negations
    if sentence.is_a? self.class and sentence.sentence.is_atomic?
      sentence.sentence
    else
      Negation.new(sentence.elim_double_negations)
    end
  end

  def de_morgans_laws
    if sentence.is_a? Conjunction
      Disjunction.new(
        Negation.new(sentence.left),
        Negation.new(sentence.right)
      )
    elsif sentence.is_a? Disjunction
      Conjunction.new(
        Negation.new(sentence.left),
        Negation.new(sentence.right)
      )
    else
      Negation.new(sentence.de_morgans_laws)
    end
  end

  def is_atomic?
    sentence.is_atomic?
  end

  def atomics
    if is_atomic?
      [self]
    else
      sentence.atomics
    end
  end

  def to_s
    "[:not #{sentence}]"
  end
end

class Atomic < Sentence
  def initialize(sentence)
    @sentence = sentence
  end

  attr_reader :sentence

  def evaluate(model)
    model[sentence]
  end

  def ==(other)
    other.is_a? Atomic and sentence == other.sentence
  end

  def symbols
    Set.new([sentence])
  end

  def eliminate_biconditionals
    self
  end

  def eliminate_conditionals
    self
  end

  def elim_double_negations
    self
  end

  def de_morgans_laws
    self
  end

  def distribute
    self
  end

  def atomics
    [self]
  end

  def is_atomic?
    true
  end

  def to_s
    sentence
  end
end

class Sentence
  class << self
    def factory(*args)
      puts args.inspect
      if args.size == 1 and args.first.is_a? String
        Atomic.new(args.first)
      elsif args.size == 2
        Negation.new(factory(*args[1]))
      elsif args.size >= 3 and args.size <= 5
        connective_index = args.find_index do |elm|
          [:and, :or, :then, :iff].include?(elm)
        end
        connective = args[connective_index]

        if connective == :and
          Conjunction.new(
            factory(*args[0...connective_index].first),
            factory(*args[connective_index+1..].first)
          )
        elsif connective == :or
          Disjunction.new(
            factory(*args[0...connective_index].first),
            factory(*args[connective_index+1..].first)
          )
        elsif connective == :then
          Conditional.new(
            factory(*args[0...connective_index].first),
            factory(*args[connective_index+1..].first)
          )
        elsif connective == :iff
          Biconditional.new(
            factory(*args[0...connective_index].first),
            factory(*args[connective_index+1..].first)
          )
        else
          raise SentenceNotWellFormedError.new("Sentence is not a well-formed formula: #{args.inspect}")
        end
      else
        raise SentenceNotWellFormedError.new("Sentence is not a well-formed formula: #{args.inspect}")
      end
    end
  end
end

class KnowledgeBase
  def initialize
    @connectives = [:and, :or, :then, :iff]
    @operators = [:not, :and, :or, :then, :iff]
    @symbols = Set.new([])
    @sentences = []
  end

  attr_reader :symbols, :connectives, :sentences

  def assert(*sentence)
    unless wff?(*sentence)
      raise SentenceNotWellFormedError.new(
        "Sentence is not a well-formed formula: #{sentence.inspect}"
      )
    end

    Sentence.factory(*sentence).then do |sentence|
      @symbols = Set.new(@symbols + sentence.symbols)
      @sentences << sentence
    end
  end

  def is_connective?(element)
    @connectives.include?(element)
  end

  def is_atomic?(element)
    element.is_a?(String)
  end

  def resolve(*query)
    prove_sent = Sentence.factory(:not, query)

    puts "prove_sent: ", prove_sent

    Sentence.factory(:not, query).then do |query|
      sentences + [query]
    end.then do |all_sentences|
      all_sent_cnf = all_sentences.map do |sentence|
        to_cnf(*sentence)
      end
      puts "all_sent_cnf: ", all_sent_cnf
      all_sent_cnf
    end.then do |all_sent_cnf|
      clauses = Set.new([])
      while not all_sent_cnf.empty?
        sent = all_sent_cnf.shift

        if sent.is_a? Conjunction
          all_sent_cnf << sent.left
          all_sent_cnf << sent.right
        else
          clauses << sent
        end
      end
      puts "clauses: ", clauses.to_a.map(&:to_s)
      clauses.to_a
    end.then do |clauses|
      while true
        new_clauses = []
        clauses.combination(2).to_a.each do |cls_a, cls_b|

          complements = find_complements(cls_a, cls_b)
          if complements.empty?
            next
          else
            resolvents = resolve_clauses(cls_a, cls_b, complements)
            if resolvents.is_a? EmptyClause
              puts "clauses: ", cls_a, cls_b, " returned the empty clause"
              return true
            elsif not new_clauses.include? resolvents
              new_clauses << resolvents
            end
          end
        end

        if new_clauses.all? { |new_cls| clauses.include? new_cls }
          return false
        else
          clauses = clauses + new_clauses.select { |new_cls| not clauses.include? new_cls }
        end
        puts "updated clause count: ", clauses.size
      end
    end
  end

  def resolve_clauses(cls_a, cls_b, complements)
    comp_a, comp_b = complements

    cls_a_atomics = cls_a.atomics
    cls_b_atomics = cls_b.atomics

    cls_a_atomics.delete_at(cls_a_atomics.index(comp_a))
    cls_b_atomics.delete_at(cls_b_atomics.index(comp_b))

    if cls_a_atomics.empty? and cls_b_atomics.empty?
      return EmptyClause.new
    end

    Set.new(cls_a_atomics + cls_b_atomics).to_a.then do |new_atomics|
      if new_atomics.size == 1
        return new_atomics.first
      else
        left, right = new_atomics.shift(2)
        new_clause = Disjunction.new(left, right)
        while not new_atomics.empty?
          new_clause = Disjunction.new(new_clause, new_atomics.shift)
        end
        new_clause
      end
    end
  end

  def find_complements(clause_a, clause_b)
    clause_a.atomics.product(clause_b.atomics).each do |atom_a, atom_b|
      if complements?(atom_a, atom_b)
        return [atom_a, atom_b]
      end
    end
    []
  end

  def complements?(a, b)
    (a.is_a?(Negation) and a.sentence == b) or (b.is_a?(Negation) and b.sentence == a)
  end

  def to_cnf(sentence)
    puts "to_cnf: ", sentence

    sentence.eliminate_biconditionals.then do |sent|
      # puts "eliminate_biconditionals: ", sent
      sent.eliminate_conditionals
    end.then do |prev|
      # puts "eliminate_conditionals: ", prev
      changing = true
      until not changing
        updated = prev.elim_double_negations
        updated = updated.de_morgans_laws

        if updated.to_s == prev.to_s
          changing = false
        else
          prev = updated
        end
      end
      # puts "handle negations: ", updated
      updated
    end.then do |sent|
      # STEP: find nested conjunctions
      distributed_sent = sent.distribute
      puts "distribute: ", distributed_sent
      distributed_sent
    end
  end

  def entail?(*query)
    Sentence.factory(*query).then do |query|
      check_truth_tables(
        query,
        Set.new(symbols + query.symbols).to_a,
        {}
      )
    end
  end

  # Determine if the query is true given the knowledge base by enumerating all truth tables.
  #
  # @param query [Sentence] The query to be evaluated.
  # @param symbols [Array] The list of symbols used in the query.
  # @param model [Hash] The model representing the truth values of the symbols.
  # @return [Boolean] Returns true if the query is true all models that the knowledge base is true.
  #
  # @note The time complexity of this method is O(2^n), where n is the number of unique symbols contained in the query and the knowledge base.
  def check_truth_tables(query, symbols=[], model={})
    if symbols.empty?
      !evaluate(model) or query.evaluate(model)
    else
      check_truth_tables(query, symbols[1..], model.merge({symbols.first => false})) \
        and check_truth_tables(query, symbols[1..], model.merge({symbols.first => true}))
    end
  end

  def evaluate(model)
    @sentences.all? do |sentence|
      sentence.evaluate(model)
    end
  end

  def wff?(*sentence)
    if sentence.length == 1 and is_atomic?(sentence[0])
      true
    elsif sentence.length == 2 and sentence[0] == :not
      is_atomic?(sentence[1]) or wff?(*sentence[1])
    elsif sentence.size == 3 and is_connective?(sentence[1])
      wff?(*sentence[0]) and wff?(*sentence[2])
    elsif sentence.size == 4 and is_connective?(sentence[1])
      wff?(*sentence[0]) and wff?(*sentence[2..])
    elsif sentence.size >= 2 and sentence[0] == :not and is_connective?(sentence[2])
      wff?(*sentence[0..1]) and wff?(*sentence[3..])
    else
      false
    end
  end
end

def knowledge_base(kb=nil, &block)
  kb = KnowledgeBase.new if kb.nil?
  kb.instance_eval(&block)
  kb
end

kb = knowledge_base do
  # NOTE: testing asserts
  # assert ["a", :and, "b"], :then, "c"
  # assert :not, "c"
  # assert [:not, "a"], :or, [:not, "b"]
  # assert "a"
  # assert "e", :then, "f"
  # assert "g", :iff, "h"
  # assert :not, "i"
  # assert "j"
  # assert ["k", :and, "l"], :or, "m"
  # assert [["k", :and, "l"], :or, ["n", :and, "o"]], :then, "p"
  # assert ["matt", :and, [:not, "ben"]], :and, "joe"

  # wff? "a"
  # wff? :not, "a"
  # wff? "b", :and, "b"
  # wff? :not, "b", :or, "b"
  # wff? "b", :or, :not, "b"
  # wff? :not, "b", :or, :not, "b"
  # wff? "a", :then, "b"
  # wff? "a", :iff, "b"
  # wff? :not, ["a", :and, "b"]
  # wff? ["a", :and, "b"], :or, :not, "c"
  # wff? :not, "a", :and, :not, "b"
  # wff? "c", :and, :not, "d"
  # wff? [["a", :and, "b"], :or, ["c", :and, :not, "d"]], :then, :not, "e"

  # entail? :not, ["a", :and, "b"]

  # TODO: to_cnf should only accept a Sentence object
  # to_cnf Sentence.factory([:not, [:not, "a"]], :iff, [:not, [:not, "b"]])
  # to_cnf Sentence.factory([[:not, "b"], :or, "c"], :then, "a")
  # to_cnf Sentence.factory(["a", :iff, "b"], :or, ["d", :iff, "c"])
  # to_cnf Sentence.factory(:not, ["a", :and, "b"])
  # to_cnf Sentence.factory(:not, ["a", :or, "b"])
  # to_cnf Sentence.factory(:not, [["a", :then, "c"], :and, ["b", :then, "d"]])
  # puts to_cnf Sentence.factory(["a", :and, "b"], :iff, "c")

  # NOTE: setting resolution
  # assert :not, ["a", :and, "b"]
  assert ["a", :and, "c"], :iff, "b"
  assert "b"
  # assert "c", :then, "d"
  puts resolve "d"
  puts resolve "a", :and, "c"
  # puts complements? Negation.new(Atomic.new("a")), Atomic.new("a")
  # puts complements? Atomic.new("a"), Negation.new(Atomic.new("a"))
  # puts complements? Atomic.new("a"), Negation.new(Atomic.new("b"))
end

# puts kb.entail? :not, ["a", :and, "b"]
# puts kb.entail? :not, "b"


# binding.pry

# puts kb.symbols
# puts "----------------------"
# puts kb.sentences.inspect