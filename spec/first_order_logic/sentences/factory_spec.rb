require "spec_helper"
require 'date'

describe RuleRover::FirstOrderLogic::Sentences::Factory do
  it "does not raise" do
    expect { described_class.new }.not_to raise_error
  end

  class CustomDataType; end

  describe ".build" do
    describe "when given a term" do
      describe "when given a constant symbol" do
        context "when given a string" do
          it "returns a ConstantSymbol object" do
            expect(described_class.build("Aristotle")).to be_a RuleRover::FirstOrderLogic::Sentences::ConstantSymbol
          end
        end
        context "when given a numeric" do
          it "returns a ConstantSymbol object" do
            expect(described_class.build(1)).to be_a RuleRover::FirstOrderLogic::Sentences::ConstantSymbol
          end
        end
        context "when given a date" do
          it "returns a ConstantSymbol object" do
            expect(described_class.build(Date.new(2024, 1, 1))).to be_a RuleRover::FirstOrderLogic::Sentences::ConstantSymbol
          end
        end
        context "when given a custom datatype" do
          it "returns a ConstantSymbol object" do
            expect(described_class.build(CustomDataType.new)).to be_a RuleRover::FirstOrderLogic::Sentences::ConstantSymbol
          end
        end
      end
      describe "when given a function symbol" do
        it "returns a FunctionSymbol" do
          expect(
            described_class.build(
              :@teacher_of,
              "Aristotle"
            )
          ).to be_a RuleRover::FirstOrderLogic::Sentences::FunctionSymbol
        end
        context 'with custom data type' do
          it "returns a FunctionSymbol" do
            sentence = described_class.build(
              :@deceased,
              Date.new(2024, 1, 1)
            )
            expect(sentence).to be_a RuleRover::FirstOrderLogic::Sentences::FunctionSymbol
          end
        end
      end
      describe "when given a predicate symbol" do
        it "returns a PredicateSymbol" do
          expect(described_class.build("Plato", :taught,
                                       "Aristotle")).to be_a RuleRover::FirstOrderLogic::Sentences::PredicateSymbol
        end
      end
      describe "when given a variable" do
        it "returns a Variable" do
          expect(described_class.build("x")).to eq RuleRover::FirstOrderLogic::Sentences::Variable.new("x")
        end
      end
    end

    describe "when given a negation" do
      it do
        expect(
          described_class.build(:not, [["Plato", :taught, "Aristotle"], :and, ["Aristotle", :taught, "Alexander"]])
        ).to be_a RuleRover::FirstOrderLogic::Sentences::Negation
      end
      it do
        expect(
          described_class.build(["Plato", :taught, "Aristotle"], :and, :not, ["Aristotle", :taught, "Alexander"]).to_s
        ).to eq "[[Plato :taught Aristotle] :and [:not [Aristotle :taught Alexander]]]"
      end
      it do
        expect(
          described_class.build(:not, ["Plato", :taught, "Aristotle"], :and, ["Aristotle", :taught, "Alexander"]).to_s
        ).to eq "[[:not [Plato :taught Aristotle]] :and [Aristotle :taught Alexander]]"
      end
    end

    describe "when given a connector" do
      it "returns a conjunction" do
        expect(
          described_class.build(["Plato", :taught, "Aristotle"], :and, ["Aristotle", :taught, "Alexander"])
        ).to be_a RuleRover::FirstOrderLogic::Sentences::Conjunction
      end

      it "returns a disjunction" do
        expect(
          described_class.build(["Plato", :taught, "Aristotle"], :or, ["Aristotle", :taught, "Alexander"])
        ).to be_a RuleRover::FirstOrderLogic::Sentences::Disjunction
      end

      it "returns a conditional" do
        expect(
          described_class.build(["Plato", :taught, "Aristotle"], :then, ["Aristotle", :taught, "Alexander"])
        ).to be_a RuleRover::FirstOrderLogic::Sentences::Conditional
      end

      it "returns a biconditional" do
        expect(
          described_class.build(["Plato", :taught, "Aristotle"], :iff, ["Aristotle", :taught, "Alexander"])
        ).to be_a RuleRover::FirstOrderLogic::Sentences::Biconditional
      end

      it do
        expect(
          described_class.build([["Plato", :taught, "Aristotle"], :iff, :not, ["Aristotle", :taught, "Alexander"]],
                                :and, [[:@teacher_of, "Socrates"], :or, "Alcibides"]).to_s
        ).to eq "[[[Plato :taught Aristotle] :iff [:not [Aristotle :taught Alexander]]] :and [[:@teacher_of Socrates] :or Alcibides]]"
      end
    end

    describe "when given a quantifier" do
      it do
        result = described_class.build(
          :all,
          "x",
          [:all, "y", [[:@brother, "x", "y"], :then, [:@sibling, "x", "y"]]]
        ).to_s

        expect(result).to eq ":all(x) [:all(y) [[[:@brother x, y] :then [:@sibling x, y]]]]"
      end
      it do
        result = described_class.build(
          :some,
          "x",
          [:some, "y", [[:@brother, "x", "y"], :then, [:@sibling, "x", "y"]]]
        ).to_s

        expect(result).to eq ":some(x) [:some(y) [[[:@brother x, y] :then [:@sibling x, y]]]]"
      end
      it do
        result = described_class.build(
          :all,
          "x",
          [:some, "y", [["x", :taught, "y"], :then, ["y", :taught, "x"]]]
        )
        expect(result.to_s).to eq ":all(x) [:some(y) [[[x :taught y] :then [y :taught x]]]]"
      end
    end

    describe "when given equals" do
      it do
        result = described_class.build(
          "x", :equals, "y"
        )
        expect(result.to_s).to eq "[x :equals y]"
      end
      it do
        result = described_class.build(
          :some, %w[x
                    y], [[[:@brother, "x", "Richard"], :and, [:@brother, "y", "Richard"]], :and, :not, ["x", :equals, "y"]]
        )
        expect(result.to_s).to eq ":some(x, y) [[[[:@brother x, Richard] :and [:@brother y, Richard]] :and [:not [x :equals y]]]]"
      end
    end
  end
end
