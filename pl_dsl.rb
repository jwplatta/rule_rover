require 'set'

class SentenceNotWellFormedError < StandardError
  def initialize(message = "Sentence is not a well-formed formula.")
    super(message)
  end
end

class Sentence
  def initialize(sentence, knowledge_base)
    @elements = elements
    @knowledge_base = knowledge_base
  end

  attr_reader :sentence
end

class Model
  def initialize(knowledge_base)
    @truth_values = {}
  end

  def assign(sentence, value)
    raise ArgumentError unless value.is_a?(boolean)
    @truth_values[sentence] = value
  end

  def evaluate(sentence)
  end
end

class KnowledgeBase
  def initialize
    @connectives = [:and, :or, :then, :iff]
    @operators = [:not, :and, :or, :then, :iff]
    @atomic_sentences = Set.new
    @sentences = []
  end

  attr_reader :atomic_sentences, :connectives, :sentences

  def assert(*args)
    args.flatten.each do |element|
      @atomic_sentences << element if is_atomic?(element)
    end

    @sentences << args
  end

  def is_connective?(element)
    @connectives.include?(element)
  end

  def is_operater?(element)
    @operators.include?(element)
  end

  def is_atomic?(element)
    element.is_a?(String) && !is_connective?(element)
  end

  def entails?(sentence)
    return true
  end

  def wff?(*sentence)
    puts sentence.inspect

    if sentence.length == 1 and is_atomic?(sentence[0])
      true
    elsif sentence.length == 2 and sentence[0] == :not
      is_atomic?(sentence[1]) or wff? *sentence[1]
    elsif sentence.size == 3 and is_connective?(sentence[1])
      wff? *sentence[0] and wff? *sentence[2]
    elsif sentence.size == 4 and is_connective?(sentence[1])
      wff? *sentence[0] and wff? *sentence[2..]
    elsif sentence.size >= 2 and sentence[0] == :not and is_connective?(sentence[2])
      wff? *sentence[0..1] and wff? *sentence[3..]
    else
      raise SentenceNotWellFormedError.new("Sentence is not a well-formed formula: #{sentence.inspect}")
    end
  end
end

def knowledge_base(kb=nil, &block)
  kb = KnowledgeBase.new if kb.nil?
  kb.instance_eval(&block)
  kb
end

kb = knowledge_base do
  # assert "a", :and, "b"
  # assert "c", :or, "d"
  # assert "e", :then, "f"
  # assert "g", :iff, "h"
  # assert :not, "i"
  # assert "j"
  # assert ["k", :and, "l"], :or, "m"
  # assert [["k", :and, "l"], :or, ["n", :and, "o"]], :then, "p"
  # assert ["matt", :and, "ben"], :and, "joe"
  wff? "a"
  wff? :not, "a"
  wff? "b", :and, "b"
  wff? :not, "b", :or, "b"
  wff? "b", :or, :not, "b"
  wff? :not, "b", :or, :not, "b"
  wff? "a", :then, "b"
  wff? "a", :iff, "b"
  wff? :not, ["a", :and, "b"]
  wff? ["a", :and, "b"], :or, :not, "c"
  wff? :not, "a", :and, :not, "b"
  wff? "c", :and, :not, "d"
  wff? [["a", :and, "b"], :or, ["c", :and, :not, "d"]], :then, :not, "e"
end

puts kb.atomic_sentences
puts kb.sentences.inspect