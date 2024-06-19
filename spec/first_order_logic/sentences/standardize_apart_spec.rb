require "spec_helper"

describe RuleRover::FirstOrderLogic::Sentences::StandardizeApart do
  class Dummy
    include RuleRover::FirstOrderLogic::Sentences::StandardizeApart
  end

  it "does not raise" do
    expect { Dummy.new }.not_to raise_error
  end
  describe "#standardize_apart" do
    it "standardizes a variable" do
      sentence = sentence_factory.build("x")
      standardize_aparted_sent = Dummy.new.standardize_apart(sentence)
      expect(standardize_aparted_sent).to eq(sentence_factory.build("x_1"))
    end
    it "returns constant with mapping" do
      sentence = sentence_factory.build("Aristotle")
      standardize_aparted_sent = Dummy.new.standardize_apart(sentence)

      expect(standardize_aparted_sent).to eq(sentence)
    end
    it "standardizes apart a function symbol with a constant" do
      sentence = sentence_factory.build(:@student_of, "Aristotle")
      standardize_aparted_sent = Dummy.new.standardize_apart(sentence)
      expect(standardize_aparted_sent).to eq(sentence)
    end
    it "standardizes apart a function symbol with a variable" do
      sentence = sentence_factory.build(:@student_of, "x")
      standardize_aparted_sent = Dummy.new.standardize_apart(sentence)
      expect(standardize_aparted_sent).to eq(sentence_factory.build(:@student_of, "x_1"))
    end
    it "standardizes apart a predicate symbol with a constant" do
      sentence = sentence_factory.build("Plato", :taught, "Aristotle")
      standardize_aparted_sent = Dummy.new.standardize_apart(sentence)
      expect(standardize_aparted_sent).to eq(sentence)
    end
    it "standardizes apart a predicate symbol with a variable" do
      sentence = sentence_factory.build("x_2", :taught, "Aristotle")
      standardize_aparted_sent = Dummy.new.standardize_apart(sentence)
      expect(standardize_aparted_sent).to eq(sentence_factory.build("x_1", :taught, "Aristotle"))
    end
    it "standardizes apart a conjunction with constants" do
      sentence = sentence_factory.build("Aristotle", :and, "Plato")
      standardize_aparted_sent = Dummy.new.standardize_apart(sentence)
      expect(standardize_aparted_sent).to eq(sentence)
    end
    it "standardizes apart a conjunction of predicates with variables and constants" do
      sentence = sentence_factory.build(["Plato", :taught, "Aristotle"], :and, ["Plato", :student_of, "x"])
      standardize_aparted_sent = Dummy.new.standardize_apart(sentence)
      expect(standardize_aparted_sent).to eq(sentence_factory.build(["Plato", :taught, "Aristotle"], :and,
                                                                    ["Plato", :student_of, "x_1"]))
    end
    it "standardizes apart quantifiers" do
      sentence = sentence_factory.build(
        :some,
        "x",
        [:all, "y", [[:@brother, "Matt"], :then, ["x", :sibling_of, "y"]]]
      )
      standardize_aparted_sent = Dummy.new.standardize_apart(sentence)
      expected = sentence_factory.build(
        :some,
        "x_1",
        [:all, "x_2", [[:@brother, "Matt"], :then, ["x_1", :sibling_of, "x_2"]]]
      )
      expect(standardize_aparted_sent).to eq(expected)
    end
    it "standardizes apart equals" do
      sentence = sentence_factory.build(
        :some, %w[x
                  y], [[[:@brother, "x", "Richard"], :and, [:@brother, "y", "Richard"]], :and, :not, ["x", :equals, "z"]]
      )
      standardize_aparted_sent = Dummy.new.standardize_apart(sentence)
      expected = sentence_factory.build(
        :some, %w[x_1
                  x_2], [[[:@brother, "x_1", "Richard"], :and, [:@brother, "x_2", "Richard"]], :and, :not, ["x_1", :equals, "x_3"]]
      )
      expect(standardize_aparted_sent).to eq(expected)
    end
    context "when reset variable count is true" do
      it do
        sentence = sentence_factory.build("x")
        std_sent_a = Dummy.new.standardize_apart(
          sentence,
          reset_var_count: true
        )
        std_sent_b = Dummy.new.standardize_apart(
          sentence,
          reset_var_count: true
        )
        expect(std_sent_a).to eq(sentence_factory.build("x_1"))
        expect(std_sent_b).to eq(sentence_factory.build("x_1"))
      end
    end
    context "store is true" do
      it "persists the standardization on the sentence" do
        sentence = sentence_factory.build("y", :debates, "Aristotle")
        std_sent = Dummy.new.standardize_apart(sentence, store: true)

        expect(std_sent.standardization).to eq(
          { sentence_factory.build("y") => sentence_factory.build("x_1") }
        )
      end
    end
  end

  def sentence_factory
    RuleRover::FirstOrderLogic::Sentences::Factory
  end
end
