require 'pry'
require 'set'

class SentenceNotWellFormedError < StandardError
  def initialize(message = "Sentence is not a well-formed formula.")
    super(message)
  end
end

class Sentence
  def evaluate(model)
    raise NotImplementedError
  end

  def symbols
    raise NotImplementedError
  end

  def to_s
    raise NotImplementedError
  end
end

class Conjunction < Sentence
  def initialize(left, right)
    @left_sentence = left
    @right_sentence = right
  end

  attr_reader :left_sentence, :right_sentence, :operator

  def evaluate(model)
    left_sentence.evaluate(model) and right_sentence.evaluate(model)
  end

  def symbols
    Set.new(left_sentence.symbols + right_sentence.symbols)
  end

  def to_s
    [left_sentence.to_s, :and, right_sentence.to_s].inspect
  end
end

class Disjunction < Sentence
  def initialize(left, right)
    @left_sentence = left
    @right_sentence = right
  end

  attr_reader :left_sentence, :right_sentence, :operator

  def evaluate(model)
    left_sentence.evaluate(model) or right_sentence.evaluate(model)
  end

  def symbols
    Set.new(left_sentence.symbols + right_sentence.symbols)
  end

  def to_s
    [left_sentence.to_s, :or, right_sentence.to_s].inspect
  end
end

class Conditional < Sentence
  def initialize(left, right)
    @left_sentence = left
    @right_sentence = right
  end

  attr_reader :left_sentence, :right_sentence, :operator

  def evaluate(model)
    !left_sentence.evaluate(model) or right_sentence.evaluate(model)
  end

  def symbols
    Set.new(left_sentence.symbols + right_sentence.symbols)
  end

  def to_s
    [left_sentence.to_s, :then, right_sentence.to_s].inspect
  end
end

class Biconditional < Sentence
  def initialize(left, right)
    @left_sentence = left
    @right_sentence = right
  end

  attr_reader :left_sentence, :right_sentence, :operator

  def evaluate(model)
    left_sentence.evaluate(model) == right_sentence.evaluate(model)
  end

  def symbols
    Set.new(left_sentence.symbols + right_sentence.symbols)
  end

  def to_s
    [left_sentence.to_s, :iff, right_sentence.to_s].inspect
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

  def to_s
    [:not, sentence.to_s].inspect
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

  def to_s
    sentence
  end
end

class Sentence
  class << self
    def factory(*args)
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

  def entail?(*sentence)
    Sentence.factory(*sentence).then do |query|
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
  assert ["a", :and, "b"], :then, "c"
  assert :not, "c"
  assert "a"
  # assert "e", :then, "f"
  # assert "g", :iff, "h"
  # assert :not, "i"
  # assert "j"
  # assert ["k", :and, "l"], :or, "m"
  # assert [["k", :and, "l"], :or, ["n", :and, "o"]], :then, "p"
  # assert ["matt", :and, "ben"], :and, "joe"
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
  entail? :not, ["a", :and, "b"]
end

puts kb.entail? :not, ["a", :and, "b"]
puts kb.entail? :not, "b"


# binding.pry

# puts kb.symbols
# puts "----------------------"
# puts kb.sentences.inspect