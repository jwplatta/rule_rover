Tuple = Struct.new(:predicate, :constants) do
  # NOTE: order of constants is meaningful
  def to_s
    "#{predicate}(#{constants.join(', ')})"
  end

  def cardinality
    constants.size
  end

  def self.create_attributes(num_constants)
    num_constants.times do |i|
      define_method("constant_#{i+1}") do
        constants[i]
      end

      define_method("constant_#{i+1}=") do |value|
        constants[i] = value
      end
    end
  end
end

Rule = Struct.new(:antecedent, :consequent)


class Predicate
end

class ConstantSymbol
end

class FunctionSymbol
end

class KnowledgeBase
  def initialize
    @facts = []
    @rules = []
    @constants = []
    @functions = []
    # NOTE: terms = constants + functions
    @predicates = []
  end

  attr_reader :facts, :rules

  def assert(*args)
    # TODO: forward chaining
    @facts << Tuple.new(args[0], args[1..].flatten)
  end

  def add_rule(*args)
    # TODO: forward chaining through all the existing facts?
    @rules << Rule.new(
      Tuple.new(args[0][0], args[0][1..].flatten),
      Tuple.new(args[1][0], args[1][1..].flatten),
    )
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

# NOTES: term, function, predicates, constants, variables
# NOTES: variables start with lower case letter
# NOTES: constants start with upper case letter
kb = knowledge_base do
  relation [:taught, "x", "y"] do
    assert "Socrates", "Plato"
  end

  assert :taught, "Plato", "Aristotle"

  assert [:student_of, "Socrates"], :taught, "Aristotle"

  assert [:taught, [:@student_of, "Socrates"], "Aristotle"], :and, [:@is_mortal, "Socrates"]

  term [:left_leg, :x] do
    assert "Socrates"
    assert "Plato"
    assert "Aristotle"
  end

  function [:son_of, "x", "y"] do
    assert "Joe", "Mary"
  end

  # NOTE: uses truth table definition of implication
  all [:human, :x], [:mortal, :x]

  all [:taught, :x, :y], [:student, :y, :x]
  # NOTE: quantifiers with multiple vars
  all [:brother, :x, :y], [:sibling, :x, :y]

  # NOTE: uses truth table definition of conjunction
  some [:human, :x], [:philosopher, :x]

  # NOTE: mixed quantifiers
  # NOTE: enforce using differen variables for nested quantifiers
  # NOTE: "everybody loves someone"
  all [:loves, :x, :y] do
    some :y
  end

  # NOTE: there is someone who is loved by everyone
  some [:loves, :x, :y] do
    all :x
  end

  assert :all do
  end

  assert :some do
  end

  # NOTE: equality
  equals [:teacher, "Aristotle"], "Plato"

  # NOTE: Joe has at least two brothers
  assert :some, :x, [[:brother, :x, "Joe"], :and, [:brother, :y, "Joe"]] do
    not_equals :x, :y
  end

  assert [:some, :x, [[:brother, :x, "Joe"], :and, [:brother, :y, "Joe"]]], :then, [:all, :x, [:equals, :x, "Joe"]]

  # NOTE: Joe has exactly two brothers, Matt and Ben
  assert [:brother, "Joe", "Matt"], :and, [:brother, "Joe", "Ben"] do
    not_equals "Matt", "Ben"
    all [:brother, "Joe", :x], [[:equals, :x, "Matt"], :or, [:equals, :x, "Ben"]]
  end

  # NOTE: queries
  query do
    some [:person, :x]
  end

  # NOTE: universal instantiation, substitution, ground terms
  # terms "socrates", "plato", "aristotle", [:left_leg, :x]
  # assert :debated, "plato", "aristotle"
  # assert :human, "socrates"
  # assert :human, :x
  # assert :taught, "socrates", "plato"
  # add_rule [:human, :x], [:mortal, :x]
  # add_rule [:taught, :X, :Y], [:student, :Y, :X]
  # add_rule [:friend, :X, :Y], [:friend, :Y, :X]
end

kb2 = knowledge_base do
  assert "a", :or, "b"
  assert [["a", :or, "b"], :and, "c"]
end

puts kb.facts
puts kb.rules.inspect

first_fact = kb.facts.first
first_rule = kb.rules.first

if first_rule.antecedent.predicate == first_fact.predicate
  # TODO: apply rule
end

puts kb.facts

updated_kb = assert kb do
  assert :friend, "socrates", "aristotle"
end

puts updated_kb.facts