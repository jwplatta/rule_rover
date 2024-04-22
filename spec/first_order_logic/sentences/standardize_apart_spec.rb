require 'spec_helper'

describe RuleRover::FirstOrderLogic::Sentences::StandardizeApart do
  it 'does not raise' do
    expect { described_class.new(nil) }.not_to raise_error
  end
  describe '#transform' do
    it 'transforms a variable' do
      sentence = sentence_factory.build('x')
      transformed_sent = described_class.new(sentence).transform
      expect(transformed_sent).to eq(sentence_factory.build('x_1'))
    end
    it 'returns constant with mapping' do
      sentence = sentence_factory.build('Aristotle')
      transformed_sent = described_class.new(sentence).transform

      expect(transformed_sent).to eq(sentence)
    end
    it 'transforms a function symbol with a constant' do
      sentence = sentence_factory.build(:@student_of, 'Aristotle')
      transformed_sent = described_class.new(sentence).transform
      expect(transformed_sent).to eq(sentence)
    end
    it 'transforms a function symbol with a variable' do
      sentence = sentence_factory.build(:@student_of, 'x')
      transformed_sent = described_class.new(sentence).transform
      expect(transformed_sent).to eq(sentence_factory.build(:@student_of, 'x_1'))
    end
    it 'transforms a predicate symbol with a constant' do
      sentence = sentence_factory.build('Plato', :taught, 'Aristotle')
      transformed_sent = described_class.new(sentence).transform
      expect(transformed_sent).to eq(sentence)
    end
    it 'transforms a predicate symbol with a variable' do
      sentence = sentence_factory.build('x_2', :taught, 'Aristotle')
      transformed_sent = described_class.new(sentence).transform
      expect(transformed_sent).to eq(sentence_factory.build('x_1', :taught, 'Aristotle'))
    end
    it 'transforms a conjunction with constants' do
      sentence = sentence_factory.build('Aristotle', :and, 'Plato')
      transformed_sent = described_class.new(sentence).transform
      expect(transformed_sent).to eq(sentence)
    end
    it 'transforms a conjunction of predicates with variables and constants' do
      sentence = sentence_factory.build(['Plato', :taught, 'Aristotle'], :and, ['Plato', :student_of, 'x'])
      transformed_sent = described_class.new(sentence).transform
      expect(transformed_sent).to eq(sentence_factory.build(['Plato', :taught, 'Aristotle'], :and, ['Plato', :student_of, 'x_3']))
    end
    it 'transforms quantifiers' do
      sentence = sentence_factory.build(
        :some,
        "x",
        [:all, "y", [[:@brother, "Matt"], :then, ["x", :sibling_of, "y"]]]
      )
      transformed_sent = described_class.new(sentence).transform
      expected = sentence_factory.build(
        :some,
        "x_1",
        [:all, "x_2", [[:@brother, "Matt"], :then, ["x_1", :sibling_of, "x_2"]]]
      )
      expect(transformed_sent).to eq(expected)
    end
    it 'transforms equals' do
      sentence = sentence_factory.build(
        :some, ["x", "y"], [[[:@brother, "x", "Richard"], :and, [:@brother, "y", "Richard"]], :and, :not, ["x", :equals, "z"]]
      )
      transformed_sent = described_class.new(sentence).transform
      expected = sentence_factory.build(
        :some, ["x_1", "x_2"], [[[:@brother, "x_1", "Richard"], :and, [:@brother, "x_2", "Richard"]], :and, :not, ["x_1", :equals, "x_4"]]
      )
      expect(transformed_sent).to eq(expected)
    end
  end

  def sentence_factory
    RuleRover::FirstOrderLogic::Sentences::Factory
  end
end