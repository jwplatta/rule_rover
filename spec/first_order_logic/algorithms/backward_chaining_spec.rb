require "spec_helper"

describe RuleRover::FirstOrderLogic::Algorithms::BackwardChaining do
  describe ".backward_chain" do
    context "knowledge base contains the query" do
      it "returns an empty substitution" do
        kb = RuleRover::FirstOrderLogic::KnowledgeBase.new
        kb.assert([:not, ["Alexander", :taught, "Aristotle"]], :or, ["Socrates", :taught, "Plato"])
        kb.assert("Alexander", :taught, "Aristotle")
        query = sentence_factory.build("Alexander", :taught, "Aristotle")
        result = described_class.backward_chain(kb, query)

        expect(result).to eq({})
      end
    end
    context "knowledge base does not imply the query" do
      it "returns false" do
        kb = RuleRover::FirstOrderLogic::KnowledgeBase.new
        kb.assert(["Alexander", :taught, "Aristotle"], :then, ["Socrates", :taught, "Plato"])
        kb.assert("Alexander", :taught, "Aristotle")
        query = sentence_factory.build("Kierkegaard", :taught, "Nietzsche")
        result = described_class.backward_chain(kb, query)

        expect(result).to eq(false)
      end
    end
    context "knowledge base does not contain the query" do
      it "returns an empty substitution" do
        kb = RuleRover::FirstOrderLogic::KnowledgeBase.new
        kb.assert(["Alexander", :taught, "Aristotle"], :then, ["Socrates", :taught, "Plato"])
        kb.assert("Alexander", :taught, "Aristotle")
        query = sentence_factory.build("Socrates", :taught, "Plato")
        result = described_class.backward_chain(kb, query)

        expect(result).to eq({})
      end
      it "returns an empty substitution" do
        kb = RuleRover::FirstOrderLogic::KnowledgeBase.new
        kb.assert([["Socrates", :taught, "Plato"], :and, ["Plato", :taught, "Aristotle"]], :then,
                  ["Alexander", :knows_about, "Socrates"])
        kb.assert("Socrates", :taught, "Plato")
        kb.assert("Plato", :taught, "Aristotle")
        query = sentence_factory.build("Alexander", :knows_about, "Socrates")
        substitution = described_class.backward_chain(kb, query)
        expect(substitution).to eq({})
      end
      it "returns an empty substitution" do
        kb = RuleRover::FirstOrderLogic::KnowledgeBase.new
        kb.assert(["Socrates", :knows, "Plato"], :then, ["Plato", :knows, "Aristotle"])
        kb.assert(["Plato", :knows, "Aristotle"], :then, ["Aristotle", :knows, "Alexander"])
        kb.assert("Socrates", :knows, "Plato")
        query = sentence_factory.build("Aristotle", :knows, "Alexander")
        substitution = described_class.backward_chain(kb, query)

        expect(substitution).to eq({})
      end
      it "returns an empty substitution" do
        kb = RuleRover::FirstOrderLogic::KnowledgeBase.new
        kb.assert([["Russell", :studied, "Plato"], :and, ["Socrates", :knows, "Plato"]], :then,
                  ["Plato", :knows, "Aristotle"])
        kb.assert(["Plato", :knows, "Aristotle"], :then, ["Aristotle", :knows, "Alexander"])
        kb.assert(["Moore", :studied, "Plato"], :then, ["Russell", :studied, "Plato"])
        kb.assert("Moore", :studied, "Plato")
        kb.assert("Socrates", :knows, "Plato")
        query = sentence_factory.build("Aristotle", :knows, "Alexander")
        substitution = described_class.backward_chain(kb, query)

        expect(substitution).to eq({})
      end
    end
    context "knowledge base contains a sentence with a variable" do
      it "returns a valid substitution" do
        kb = RuleRover::FirstOrderLogic::KnowledgeBase.new
        kb.assert([["Russell", :studied, "x"], :and, ["Socrates", :knows, "x"]], :then, ["x", :knows, "Aristotle"])
        kb.assert(["Plato", :knows, "x"], :then, ["x", :knows, "Alexander"])
        kb.assert(["Moore", :studied, "x"], :then, ["Russell", :studied, "x"])
        kb.assert("Moore", :studied, "Plato")
        kb.assert("Socrates", :knows, "Plato")
        query = sentence_factory.build("Aristotle", :knows, "Alexander")
        substitution = described_class.backward_chain(kb, query)

        expect(substitution).to include(
          sentence_factory.build("x_2") => sentence_factory.build("Aristotle"),
          sentence_factory.build("x_1") => sentence_factory.build("Plato")
        )
      end
    end
    context "knowledge base contains actions" do
      it "executes the actions" do
        kb = RuleRover::FirstOrderLogic::KnowledgeBase.new
        kb.assert([["Russell", :studied, "x"], :and, ["Socrates", :knows, "x"]], :then, ["x", :knows, "Aristotle"]) do
          do_action :knows_aristotle, philosopher: "x" do |philosopher:|
            "#{philosopher} knows Aristotle"
          end
        end
        kb.assert(["Plato", :knows, "x"], :then, ["x", :knows, "Alexander"]) do
          do_action :knows_alexander, philosopher: "x" do |philosopher:|
            "#{philosopher} knows Alexander"
          end
        end
        kb.assert(["Moore", :studied, "x"], :then, ["Russell", :studied, "x"])
        kb.assert("Moore", :studied, "Plato")
        kb.assert("Socrates", :knows, "Plato")

        expect(kb).to receive(:call_rule_actions).at_least(5).times

        query = sentence_factory.build("Aristotle", :knows, "Alexander")
        described_class.backward_chain(kb, query)
      end
    end
  end
  def sentence_factory
    RuleRover::FirstOrderLogic::Sentences::Factory
  end
end
