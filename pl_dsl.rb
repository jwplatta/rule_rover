require 'pry'
require 'set'

CONNECTIVES=[:and, :or, :then, :iff]
OPERATORS=[:not, :and, :or, :then, :iff]

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
    end.then do |sent|
      sent.distribute
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

  def atoms
    left.atoms + right.atoms
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

  attr_reader :left, :right

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

  def is_definite?
    sents = [left, right]
    post_cnt = 0
    while not sents.empty?
      sent sents.unshift
      if sent.positive?
        post_cnt += 1
      elsif (sent.left.is_a? Disjunction or sent.left.is_atomic?) \
        and (sent.right.is_a? Disjunction or sent.right.is_atomic?)
        sents << sent.left
        sents << sent.right
      end

      return false if post_cnt > 1
    end

    if post_cnt == 1
      true
    else
      false
    end
  end

  def is_horn?
    sents = [left, right]
    post_cnt = 0
    while not sents.empty?
      sent sents.unshift
      if sent.positive?
        post_cnt += 1
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

  def atoms
    left.atoms + right.atoms
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

  attr_reader :left, :right

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

  def is_definite?
    false
  end

  def is_positive?
    false
  end

  def atoms
    left.atoms + right.atoms
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

  def atoms
    left.atoms + right.atoms
  end

  def is_positive?
    false
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

  def is_positive?
    false
  end

  def is_atomic?
    sentence.is_atomic?
  end

  def atoms
    if is_atomic?
      [self]
    else
      sentence.atoms
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

  def atoms
    [self]
  end

  def is_positive?
    true
  end

  def is_definite?
    true
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
      unless wff?(*args)
        raise SentenceNotWellFormedError.new("Sentence is not a well-formed formula: #{args.inspect}")
      end

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

    def wff?(*sentence)
      if sentence.length == 1 and sentence[0].is_a? String
        true
      elsif sentence.length == 2 and sentence[0] == :not
        sentence[1].is_a? String or wff?(*sentence[1])
      elsif sentence.size == 3 and CONNECTIVES.include?(sentence[1])
        wff?(*sentence[0]) and wff?(*sentence[2])
      elsif sentence.size == 4 and CONNECTIVES.include?(sentence[1])
        wff?(*sentence[0]) and wff?(*sentence[2..])
      elsif sentence.size >= 2 and sentence[0] == :not and CONNECTIVES.include?(sentence[2])
        wff?(*sentence[0..1]) and wff?(*sentence[3..])
      else
        false
      end
    end
  end
end

class KnowledgeBase
  def initialize(engine=:model_checking)
    @connectives = [:and, :or, :then, :iff]
    @operators = [:not, :and, :or, :then, :iff]
    @symbols = Set.new([])
    @sentences = []
    @engine = engine
  end

  attr_reader :symbols, :connectives, :sentences, :engine

  def assert(*sentence)
    sentence_factory(*sentence).then do |sentence|
      @symbols = Set.new(@symbols + sentence.symbols)
      @sentences << sentence
    end
  end

  def entail?(*query)
    if engine == :model_checking
      ModelChecking.run(self, *query)
    elsif engine == :resolution
      Resolution.run(self, *query)
    else
      raise ArgumentError.new("Engine not supported: #{engine}")
    end
  end

  private

  def sentence_factory(*args)
    Sentence.factory(*args)
  end
end

class InferenceAlgorithm
  class << self
    def run(kb, *query)
      self.new(kb, *query).entail?
    end
  end

  def initialize(kb, *query)
    @kb = kb
    @query = query
  end

  attr_reader :kb, :query

  def entail?
    raise NotImplementedError
  end

  private

  def sentence_factory(*args)
    Sentence.factory(*args)
  end
end

class Resolution < InferenceAlgorithm
  def entail?
    sentence_factory(:not, query).then do |query|
      kb.sentences + [query]
    end.then do |all_sentences|
      all_sentences.map do |sentence|
        sentence.to_cnf
      end
    end.then do |all_sent_cnf|
      find_clauses(all_sent_cnf)
    end.then do |clauses|
      resolve(clauses)
    end
  end

  private

  def resolve(clauses)
    new_clauses = []
    clauses.combination(2).to_a.each do |cls_a, cls_b|
      complements = first_complements(cls_a, cls_b)
      if complements.empty?
        next
      else
        resolve_clauses(cls_a.atoms, cls_b.atoms, *complements).then do |new_clause|
          if new_clause.is_a? EmptyClause
            return true
          elsif not new_clauses.include? new_clause
            new_clauses << new_clause
          end
        end
      end
    end

    if new_clauses.all? { |new_cls| clauses.include? new_cls }
      return false
    else
      resolve(clauses + new_clauses.select { |new_cls| not clauses.include? new_cls })
    end
  end

  def find_clauses(sentences)
    # NOTE: assumes that the sentences are in CNF
    clauses = []
    while not sentences.empty?
      sent = sentences.shift

      if sent.is_a? Conjunction
        sentences << sent.left
        sentences << sent.right
      elsif not clauses.include? sent
        clauses << sent
      end
    end
    clauses
  end

  def resolve_clauses(cls_a_atoms, cls_b_atoms, comp_a, comp_b)
    cls_a_atoms.delete_at(cls_a_atoms.index(comp_a))
    cls_b_atoms.delete_at(cls_b_atoms.index(comp_b))

    if cls_a_atoms.empty? and cls_b_atoms.empty?
      EmptyClause.new
    else
      Set.new(cls_a_atoms + cls_b_atoms).to_a.then do |new_atoms|
        if new_atoms.size == 1
          new_atoms.first
        else
          left, right = new_atoms.shift(2)

          new_clause = Disjunction.new(left, right)
          while not new_atoms.empty?
            new_clause = Disjunction.new(new_clause, new_atoms.shift)
          end
          new_clause
        end
      end
    end
  end

  def first_complements(clause_a, clause_b)
    clause_a.atoms.product(clause_b.atoms).find do |atomic_a, atomic_b|
      complements?(atomic_a, atomic_b)
    end || []
  end

  def complements?(a, b)
    (a.is_a?(Negation) and a.sentence == b) or (b.is_a?(Negation) and b.sentence == a)
  end
end


class ModelChecking < InferenceAlgorithm
  def entail?
    sentence_factory(*query).then do |query|
      check_truth_tables(
        query,
        Set.new(kb.symbols + query.symbols).to_a,
        {}
      )
    end
  end

  private

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
    kb.sentences.all? do |sentence|
      sentence.evaluate(model)
    end
  end
end

def knowledge_base(kb=nil, &block)
  kb = KnowledgeBase.new(engine=:resolution) if kb.nil?
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
  # puts sentences
  # assert "ben", :and, :or, "matt"

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

  # puts entail? :not, ["a", :and, "b"]

  # TODO: to_cnf should only accept a Sentence object
  # puts to_cnf Sentence.factory([:not, [:not, "a"]], :iff, [:not, [:not, "b"]])
  # puts to_cnf Sentence.factory([[:not, "b"], :or, "c"], :then, "a")
  # puts to_cnf Sentence.factory(["a", :iff, "b"], :or, ["d", :iff, "c"])
  # puts to_cnf Sentence.factory(:not, ["a", :and, "b"])
  # puts to_cnf Sentence.factory(:not, ["a", :or, "b"])
  # puts to_cnf Sentence.factory(:not, [["a", :then, "c"], :and, ["b", :then, "d"]])
  # puts to_cnf Sentence.factory(["a", :and, "b"], :iff, "c")

  # NOTE: setting resolution
  assert :not, ["a", :and, "b"]
  assert "x", :then, "y"
  assert :not, "y"
  puts entail? :not, "x"

  assert ["a", :and, "c"], :iff, "b"
  assert "b"
  puts entail? "a", :and, "c"
  # puts resolution "a"
  # puts resolution "d"
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