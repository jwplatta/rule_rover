require "spec_helper"

describe RuleRover::FirstOrderLogic::Sentences::Conditional do
  describe "#conditions" do
    it do
      sent = sentence_factory.build("x", :then, "y")
      expect(sent.conditions).to eq([
                                      sentence_factory.build("x")
                                    ])
    end
    it do
      sent = sentence_factory.build(
        [["Aristotle", :taught, "Alexander"], :and, ["Socrates", :taught, "Plato"]], :then, "y"
      )
      expect(sent.conditions).to eq([
                                      sentence_factory.build("Aristotle", :taught, "Alexander"),
                                      sentence_factory.build("Socrates", :taught, "Plato")
                                    ])
    end
    context "when the sentence is not a definite clause" do
      it "raises an error" do
        sent = sentence_factory.build(["x", :or, "y"], :then, "z")
        expect { sent.conditions }.to raise_error(RuleRover::FirstOrderLogic::SentenceNotDefiniteClause)
      end
    end
  end

  def sentence_factory
    RuleRover::FirstOrderLogic::Sentences::Factory
  end
end
