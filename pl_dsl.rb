require 'pry'
require 'set'

class SentenceNotWellFormedError < StandardError
  def initialize(message = "Sentence is not a well-formed formula.")
    super(message)
  end
end

class Conjunction
  def initialize(left, right)
    @left_sentence = left
    @right_sentence = right
  end

  attr_reader :left_sentence, :right_sentence, :operator

  def true?
    left_sentence.true? and right_sentence.true?
  end

  def is_atomic?
    false
  end
end

class Disjunction
  def initialize(left, right)
    @left_sentence = left
    @right_sentence = right
  end

  attr_reader :left_sentence, :right_sentence, :operator

  def true?
    left_sentence.true? or right_sentence.true?
  end

  def is_atomic?
    false
  end
end

class Conditional
  def initialize(left, right)
    @left_sentence = left
    @right_sentence = right
  end

  attr_reader :left_sentence, :right_sentence, :operator

  def true?
    !left_sentence.true? or right_sentence.true?
  end

  def is_atomic?
    false
  end
end

class Biconditional
  def initialize(left, right)
    @left_sentence = left
    @right_sentence = right
  end

  attr_reader :left_sentence, :right_sentence, :operator

  def true?
    left_sentence.true? == right_sentence.true?
  end

  def is_atomic?
    false
  end
end

class Negation
  def initialize(sentence)
    @sentence = sentence
  end

  attr_reader :sentence, :operator

  def true?
    !sentence.true?
  end

  def is_atomic?
    true
  end
end

class Atomic
  def initialize(sentence)
    @sentence = sentence
    @truth_value = nil
  end

  attr_reader :sentence

  def set_truth_value(value)
    @truth_value = value
  end

  def true?
    @truth_value == true
  end

  def is_atomic?
    true
  end

  def ==(other)
    other.is_a? Atomic and sentence == other.sentence
  end
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

class Sentence
  class << self
    def factory(*args)
      puts args.inspect
      if args.size == 3
        if args[1] == :and
          Conjunction.new(args[0], args[2])
        elsif args[1] == :or
          Disjunction.new(args[0], args[2])
        elsif args[1] == :then
          Conditional.new(args[0], args[2])
        elsif args[1] == :iff
          Biconditional.new(args[0], args[2])
        else
          raise SentenceNotWellFormedError.new("Sentence is not a well-formed formula: #{args.inspect}")
        end
      elsif args[0] == :not and args.size == 2
        Negation.new(args[1])
      elsif args[0] == :not and args.size > 2
        Negation.new(factory(*args[1..]))
      elsif args.size == 1
        Atomic.new(args[0])
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
    @atomic_sentences = Set.new
    @sentences = []
  end

  attr_reader :atomic_sentences, :connectives, :sentences

  def assert(*sentence)
    wff?(*sentence)


    sentence
  end

  def is_connective?(element)
    @connectives.include?(element)
  end

  def is_operator?(element)
    @operators.include?(element)
  end

  def is_atomic?(element)
    element.is_a?(String)
  end

  def true_in_model?(sentence, model)
  end

  def entails?(sentence)
    return true
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
  # assert "a"
  # assert "b"
  puts true_in_model? ["a", :and, "b"], { "a" => true, "b" => true }
  puts true_in_model? ["a", :and, "b"], { "a" => true, "b" => false }
  puts true_in_model? ["a", :or, "b"], { "a" => false, "b" => true }
  puts true_in_model? ["a", :or, "b"], { "a" => false, "b" => false }
  puts true_in_model? ["a", :iff, "b"], { "a" => true, "b" => false }
  puts true_in_model? ["a", :iff, "b"], { "a" => false, "b" => false }
  puts true_in_model? ["a", :then, "b"], { "a" => true, "b" => false }
  puts true_in_model? ["a", :then, "b"], { "a" => false, "b" => false }
  puts true_in_model? ["a", :then, "b"], { "a" => true, "b" => true }
  # assert "a", :and, "b"
  # assert "c", :or, "d"
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
  # entail? "a", :and, "b"
end


binding.pry


puts kb.atomic_sentences
puts kb.sentences.inspect