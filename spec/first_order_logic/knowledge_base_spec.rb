require "spec_helper"

describe RuleRover::FirstOrderLogic::KnowledgeBase do
  it "does not raise" do
    expect { described_class.new }.not_to raise_error
  end
  describe "#assert" do
    it "adds sentence with standardized variables" do
      expected = sentence_factory.build("x_1", :and, "x_2")
      subject.assert("a", :and, "b")
      expect(subject.sentences).to include(expected)
      expect(subject.constants.size).to eq 0
    end
    it "adds a predicate" do
      sent = ["Aristotle", :taught, "Alexander"]
      expected = sentence_factory.build(*sent)
      subject.assert(*sent)
      expect(subject.sentences).to include(expected)
      expect(subject.constants.size).to eq 2
    end
    it "adds a function" do
      expected = sentence_factory.build(:@father_of, "x_1")
      subject.assert(:@father_of, "x")
      expect(subject.sentences).to include(expected)
      expect(subject.constants.size).to eq 0
    end
    it "adds a negation" do
      expected = sentence_factory.build(:not, ["x_1", :and, "x_2"])
      subject.assert(:not, ["x", :and, "y"])
      expect(subject.sentences).to include(expected)
      expect(subject.constants.size).to eq 0
    end
    it "adds a conjunction" do
      expected = sentence_factory.build("x_1", :and, "x_2")
      subject.assert("a", :and, "b")
      expect(subject.sentences).to include(expected)
      expect(subject.constants.size).to eq 0
    end
    it "adds a disjunction" do
      expected = sentence_factory.build(["Plato", :taught, "Aristotle"], :or, ["Aristotle", :taught, "Alexander"])
      subject.assert(["Plato", :taught, "Aristotle"], :or, ["Aristotle", :taught, "Alexander"])
      expect(subject.sentences).to include(expected)
      expect(subject.constants.size).to eq 3
    end
    it "adds an implication" do
      expected = sentence_factory.build("x_1", :then, "x_2")
      subject.assert("a", :then, "b")
      expect(subject.sentences).to include(expected)
      expect(subject.constants.size).to eq 0
    end
    it "adds a biconditional" do
      expected = sentence_factory.build("x_1", :iff, "x_2")
      subject.assert("a", :iff, "b")
      expect(subject.sentences).to include(expected)
      expect(subject.constants.size).to eq 0
    end
    it "adds a universal quantifier" do
      expected = sentence_factory.build(:all, "x_1", [[:@brother, "x_2", "x_1"], :then, [:@sibling, "x_2", "x_1"]])
      subject.assert(:all, "y", [[:@brother, "x", "y"], :then, [:@sibling, "x", "y"]])
      expect(subject.sentences).to include(expected)
      expect(subject.constants.size).to eq 0
    end
    it "adds an existential quantifier" do
      expected = sentence_factory.build(:some, "x_1", [["x_2", :taught, "x_1"], :then, ["x_1", :taught, "x_2"]])
      subject.assert(:some, "y", [["x", :taught, "y"], :then, ["y", :taught, "x"]])
      expect(subject.sentences).to include(expected)
      expect(subject.constants.size).to eq 0
    end
    it "adds an equality" do
      expected = sentence_factory.build([[:@father_of, "x_1"], :and, [:@father_of, "x_2"]], :and,
                                        ["x_1", :equals, "x_2"])
      subject.assert([[:@father_of, "x"], :and, [:@father_of, "y"]], :and, ["x", :equals, "y"])
      expect(subject.sentences).to include(expected)
      expect(subject.constants.size).to eq 0
    end
  end
  describe "#retract" do
    context "when the sentence is not in the knowledge base" do
      it do
        subject.assert("Wittgenstein", :debates, "Russell")
        subject.assert("Wittgenstein", :debates, "Moore")
        subject.assert("Wittgenstein", :debates, "Frege")
        subject.assert("Wittgenstein", :debates, "Carnap")
        subject.retract("Russell", :debates, "x")

        expect(subject.sentences.size).to eq 4
      end
    end
    it "removes all sentences that match" do
      subject.assert("Wittgenstein", :debates, "Russell")
      subject.assert("Wittgenstein", :debates, "Moore")
      subject.assert("Wittgenstein", :debates, "Frege")
      subject.assert("Wittgenstein", :debates, "Carnap")
      subject.retract("Wittgenstein", :debates, "x")

      expect(subject.sentences).to eq []
    end
  end
  describe "#rule" do
    # TODO: check that the sentence is a definite clause
  end
  describe "#do_action" do
    context "when passed a valid new action" do
      it "returns the action name and the parameters" do
        result = subject.do_action :puts_expert, philosopher: "x", subject: "y" do |philosopher:, subject:|
          puts "#{philosopher} is an expert on #{subject}"
        end

        action_name, mapped_params = result

        expect(action_name).to eq :puts_expert
        expect(mapped_params).to eq({ philosopher: "x", subject: "y" })
      end
    end
    context "when passed an existing action" do
      it "returns the action name and the parameters" do
        subject.do_action :puts_expert, philosopher: "x", subject: "y" do |philosopher:, subject:|
          puts "#{philosopher} is an expert on #{subject}"
        end

        result = subject.do_action :puts_expert, philosopher: "x", subject: "y"
        action_name, mapped_params = result

        expect(action_name).to eq :puts_expert
        expect(mapped_params).to eq({ philosopher: "x", subject: "y" })
      end
    end
    context "when sentence parameters do not match the action parameters" do
      it "raises an error" do
        expect do
          subject.do_action :puts_expert, foo: "x", bar: "y" do |philosopher:, subject:|
            puts "#{philosopher} is an expert on #{subject}"
          end
        end.to raise_error(ArgumentError)
      end
    end
  end
  describe "#call_rule_actions" do
    context "when provided a substitution" do
      it "returns the result of the action" do
        subject.assert(["x", :writes_about, "y"], :then, ["x", :studies, "y"]) do
          do_action :puts_expert, philosopher: "x", subject: "y" do |philosopher:, subject:|
            "#{philosopher} is an expert on #{subject}"
          end
        end

        substitution = {
          sentence_factory.build("x_1") => sentence_factory.build("Frege"),
          sentence_factory.build("x_2") => sentence_factory.build("Logic")
        }

        result = subject.call_rule_actions(subject.sentences.last, substitution: substitution)
        expect(result).to eq(["Frege is an expert on Logic"])
      end
    end
    context "when provided a grounded sentence" do
      it "calls the action with the grounded sentence" do
        subject.assert(["x", :writes_about, "y"], :then, ["x", :studies, "y"]) do
          do_action :puts_expert, philosopher: "x", subject: "y" do |philosopher:, subject:|
            "#{philosopher} is an expert on #{subject}"
          end
        end

        action_registry = subject.action_registry
        substitution = {
          sentence_factory.build("x_1") => sentence_factory.build("Frege"),
          sentence_factory.build("x_2") => sentence_factory.build("Logic")
        }

        grounded_sentence = subject.sentences.last.substitute(substitution)

        expect(action_registry).to receive(:call_rule_actions).with(grounded_sentence)
        subject.call_rule_actions(grounded_sentence)
      end
    end
  end
  describe "#match" do
    describe "when knowledge base is empty" do
      it "returns false" do
        expect(subject.match?("Joe", :and, "Matthew")).to be false
      end
    end
    describe "when knowledge base is not empty" do
      before do
        subject.assert("Joe", :and, "Matthew")
        subject.assert("Ben", :and, "Joe")
        subject.assert("x", :and, "Joe")
      end
      context "when knowledge base contains a match" do
        it "returns sentence from knowledge base" do
          match = subject.match?("Maureen", :and, "Joe")
          expect(match).to be subject.sentences.last
        end
      end
      context "when knowledge base contains no match" do
        it "returns nil" do
          expect(subject.match?("Maureen", :and, "Monkey")).to be false
        end
      end
    end
  end
  describe "#constant" do
    it do
      subject.constant("Aristotle")
      subject.constant("Plato")
      subject.constant("Plato")
      expect(subject.constants.size).to eq 2
    end
  end
  describe "#create_constant" do
    it do
      subject.assert("C1")
      subject.assert("C3")
      new_constant = subject.create_constant

      expect(new_constant).to eq sentence_factory.build("C2")
      expect(subject.constants.size).to eq 3
    end
  end

  describe "#definite_clause?" do
    context "when sentence is not a conditional" do
      it "returns false" do
        expect(subject.send(:definite_clause?, sentence_factory.build("x", :and, "y"))).to be false
      end
    end
    context "when consequent is a negation" do
      it "returns false" do
        expect(subject.send(:definite_clause?, sentence_factory.build("x", :then, :not, "y"))).to be false
      end
    end
    context "when antecedent contains a positive literal" do
      it "returns false" do
        expect(subject.send(:definite_clause?, sentence_factory.build([:not, "z", :or, "x"], :then, "y"))).to be false
      end
    end
    context "when sentence is a definite clause" do
      it "returns true" do
        expect(subject.send(:definite_clause?, sentence_factory.build("z", :then, "y"))).to be true
      end
      it "returns true" do
        expect(subject.send(:definite_clause?, sentence_factory.build(["z", :and, "x"], :then, "y"))).to be true
      end
    end
  end

  def sentence_factory
    RuleRover::FirstOrderLogic::Sentences::Factory
  end
end
