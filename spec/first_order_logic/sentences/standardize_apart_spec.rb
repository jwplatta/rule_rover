require 'spec_helper'

describe RuleRover::FirstOrderLogic::Sentences::StandardizeApart do
  it 'does not raise' do
    expect { described_class.new(nil) }.not_to raise_error
  end
  describe '#transform' do
    it 'maps a variable' do
      sentence = sentence_factory.build('x')
      mapping = described_class.new(sentence).transform
      expect(mapping).to eq({ sentence => sentence_factory.build('x_1') })
    end
    it 'maps a constant symbol' do
      sentence = sentence_factory.build('Aristotle')
      mapping = described_class.new(sentence).transform
      expect(mapping).to eq({ sentence => sentence_factory.build('x_1') })
    end
    it 'maps a function symbol with a constant' do
      sentence = sentence_factory.build(:@student_of, 'Aristotle')
      mapping = described_class.new(sentence).transform
      expect(mapping).to eq({
        sentence_factory.build('Aristotle') => sentence_factory.build('x_1')
      })
    end
    it 'maps a function symbol with a variable' do
      sentence = sentence_factory.build(:@student_of, 'x')
      mapping = described_class.new(sentence).transform
      expect(mapping).to eq({
        sentence_factory.build('x') => sentence_factory.build('x_1')
      })
    end
    it 'maps a predicate symbol with a constant' do
      sentence = sentence_factory.build('Plato', :taught, 'Aristotle')
      mapping = described_class.new(sentence).transform
      expect(mapping).to eq({
        sentence_factory.build('Plato') => sentence_factory.build('x_1'),
        sentence_factory.build('Aristotle') => sentence_factory.build('x_2')
      })
    end
    it 'maps a predicate symbol with a variable' do
      sentence = sentence_factory.build('x_2', :taught, 'Aristotle')
      mapping = described_class.new(sentence).transform
      expect(mapping).to eq({
        sentence_factory.build('x_2') => sentence_factory.build('x_1'),
        sentence_factory.build('Aristotle') => sentence_factory.build('x_2')
      })
    end
    it 'maps a conjunction with constants' do
      sentence = sentence_factory.build('Aristotle', :and, 'Plato')
      mapping = described_class.new(sentence).transform
      expect(mapping).to eq({
        sentence_factory.build('Aristotle') => sentence_factory.build('x_1'),
        sentence_factory.build('Plato') => sentence_factory.build('x_2')
      })
    end
    it 'maps a conjunction of predicates with variables and constants' do
      sentence = sentence_factory.build(['Plato', :taught, 'Aristotle'], :and, ['Plato', :student_of, 'x'])
      mapping = described_class.new(sentence).transform

      expect(mapping).to eq({
        sentence_factory.build('Plato') => sentence_factory.build('x_1'),
        sentence_factory.build('Aristotle') => sentence_factory.build('x_2'),
        sentence_factory.build('x') => sentence_factory.build('x_3')
      })
    end
    it 'maps quantifiers' do
      sentence = sentence_factory.build(
        :some,
        "x",
        [:all, "y", [[:@brother, "Matt"], :then, ["x", :sibling_of, "y"]]]
      )
      mapping = described_class.new(sentence).transform
      expect(mapping).to eq({
        sentence_factory.build('x') => sentence_factory.build('x_1'),
        sentence_factory.build('y') => sentence_factory.build('x_2'),
        sentence_factory.build('Matt') => sentence_factory.build('x_3')
      })
    end
    it 'maps equals' do
      sentence = sentence_factory.build(
        :some, ["x", "y"], [[[:@brother, "x", "Richard"], :and, [:@brother, "y", "Richard"]], :and, :not, ["x", :equals, "z"]]
      )
      mapping = described_class.new(sentence).transform
      expect(mapping).to eq({
        sentence_factory.build('x') => sentence_factory.build('x_1'),
        sentence_factory.build('y') => sentence_factory.build('x_2'),
        sentence_factory.build('Richard') => sentence_factory.build('x_3'),
        sentence_factory.build('z') => sentence_factory.build('x_4')
      })
    end
  end

  def sentence_factory
    RuleRover::FirstOrderLogic::Sentences::Factory
  end
end