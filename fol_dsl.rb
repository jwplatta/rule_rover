Tuple = Struct.new(:predicate, :constants) do
  def to_s
    "#{predicate}(#{constants.join(', ')})"
  end

  def cardinality
    constants.size
  end
end

Rule = Struct.new(:predicate, :vars, :lambda)

class KnowledgeBase
  def initialize
    @facts = []
    @rules = []
  end

  attr_reader :facts, :rules

  def assert(*args)
    # TODO: forward chaining
    @facts << Tuple.new(args[0], args[1..].flatten)
  end

  def add_rule(*args)
    # TODO: forward chaining through all the existing facts?
    @rules << args
  end

  def query
  end

  def match(*args)
    facts.select { |fact| fact[0] == args[0] }
  end
end

def knowledge_base(kb=nil, &block)
  kb = KnowledgeBase.new if kb.nil?
  kb.instance_eval(&block)
  kb
end

def assert(kb, &block)
  kb.instance_eval(&block)
  kb
end

kb = knowledge_base do
  assert :human, "socrates"
  assert :taught, "socrates", "plato"
  assert :debated, "plato", "aristotle"
  add_rule [:human, :X], [:mortal, :X]
  add_rule [:taught, :X, :Y], [:student, :Y, :X]
  add_rule [:friend, :X, :Y], [:friend, :Y, :X]
end

puts kb.facts
puts kb.rules.inspect

first_fact = kb.facts.first
first_rule = kb.rules.first

if first_rule[0] == first_fact.predicate
  first_rule[2].call(first_fact[1])
end

puts kb.facts.inspect

updated_kb = assert kb do
  assert :friend, "socrates", "aristotle"
end

puts updated_kb.facts