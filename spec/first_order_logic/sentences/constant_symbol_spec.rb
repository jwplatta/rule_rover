require "spec_helper"

describe RuleRover::FirstOrderLogic::Sentences::ConstantSymbol do
  it "does not raise" do
    expect { described_class.new("Aristotle") }.not_to raise_error
  end

  class CustomDataType; end

  describe "#initialize" do
    it "stores the type" do
      expect(described_class.new("Aristotle").type).to eq(String)
      expect(described_class.new(1).type).to eq(Integer)
      expect(described_class.new(1.2).type).to eq(Float)
      expect(described_class.new(CustomDataType.new).type).to eq(CustomDataType)
    end
  end

  describe ".valid_name?" do
    context "when valid name" do
      context "name is a numeric" do
        it "returns true" do
          expect(described_class.valid_name?(1)).to be(true)
          expect(described_class.valid_name?(1.2)).to be(true)
        end
      end
      context "name is a string starting with a capital letter" do
        it "returns true for a string starting with a capital letter" do
          expect(described_class.valid_name?("Aristotle")).to be(true)
          expect(described_class.valid_name?("Aristotle1")).to be(true)
          expect(described_class.valid_name?("ARISTOTLE")).to be(true)
        end
      end
      context "name is a custom datatype" do
        it "return true" do
          expect(described_class.valid_name?(CustomDataType.new)).to be(true)
        end
      end
    end
    context "when invalid name" do
      it "returns false for a string starting with a lowercase letter" do
        expect(described_class.valid_name?("aristotle")).to be(false)
      end
      it "returns false for a string without non-alphanumeric" do
        expect(described_class.valid_name?("Aristotle$")).to be(false)
        expect(described_class.valid_name?("Aristotle@")).to be(false)
      end
    end
  end
end
