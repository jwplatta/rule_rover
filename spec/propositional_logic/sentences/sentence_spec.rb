require 'spec_helper'

describe RuleRover::PropositionalLogic::Sentences::Sentence do
  it 'does not raise' do
    expect { described_class.new(nil, nil) }.not_to raise_error
  end
  it 'is not atomic' do
    expect(described_class.new(nil, nil).is_atomic?).to be false
  end
  it 'is not definite' do
    expect(described_class.new(nil, nil).is_definite?).to be false
  end
  it 'is not positive' do
    expect(described_class.new(nil, nil).is_positive?).to be false
  end

  describe '#to_cnf' do
    it 'returns a sentence in conjunctive normal form' do
      tests = [
        [
          sentence_factory.build("a", :iff, "b"),
          sentence_factory.build([:not, "a", :or, "b"], :and, [:not, "b", :or, "a"])
        ],
        [
          sentence_factory.build([:not, [:not, "a"]], :iff, [:not, [:not, "b"]]),
          sentence_factory.build([:not, "a", :or, "b"], :and, [:not, "b", :or, "a"])
        ],
        [
          sentence_factory.build([[:not, "b"], :or, "c"], :then, "a"),
          sentence_factory.build(["b", :or, "a"], :and, [[:not, "c"], :or, "a"])
        ],
        [
          sentence_factory.build(["a", :iff, "b"], :or, ["d", :iff, "c"]),
          sentence_factory.build(
            [[[:not, "a"], :or, "b"], :or, [[[:not, "d"], :or, "c"], :and, [[:not, "c"], :or, "d"]]], :and, [[[:not, "b"], :or, "a"], :or, [[[:not, "d"], :or, "c"], :and, [[:not, "c"], :or, "d"]]]
          )
        ],
        [
          sentence_factory.build(:not, ["a", :and, "b"]),
          sentence_factory.build([:not, "a"], :or, [:not, "b"])
        ],
        [
          sentence_factory.build(:not, ["a", :or, "b"]),
          sentence_factory.build([:not, "a"], :and, [:not, "b"])
        ],
        [
          sentence_factory.build(:not, [["a", :then, "c"], :and, ["b", :then, "d"]]),
          sentence_factory.build(["a", :or, ["b", :and, [:not, "d"]]], :and, [[:not, "c"], :or, ["b", :and, [:not, "d"]]])
        ],
        [
          sentence_factory.build(["a", :and, "b"], :iff, "c"),
          sentence_factory.build([[[:not, "a"], :or, [:not, "b"]], :or, "c"], :and, [[[:not, "c"], :or, "a"], :and, [[:not, "c"], :or, "b"]])
        ]
      ]

      tests.each do |test|
        sentence, expects = test
        expect(sentence.to_cnf).to eq(expects)
      end
    end
  end

  def sentence_factory
    RuleRover::PropositionalLogic::Sentences::Factory
  end
end