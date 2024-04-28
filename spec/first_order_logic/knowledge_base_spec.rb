require 'spec_helper'

describe RuleRover::FirstOrderLogic::KnowledgeBase do
  fit 'does not raise' do
    expect { described_class.new }.not_to raise_error
  end
  fdescribe 'constants' do
    describe '#connectives' do
      it do
        expect(subject.connectives).to eq RuleRover::FirstOrderLogic::CONNECTIVES
      end
    end
    describe '#operators' do
      it do
        expect(subject.operators).to eq RuleRover::FirstOrderLogic::OPERATORS
      end
    end
    describe '#quantifiers' do
      it do
        expect(subject.quantifiers).to eq RuleRover::FirstOrderLogic::QUANTIFIERS
      end
    end
  end

  def sentence_factory
    RuleRover::FirstOrderLogic::Sentences::Factory
  end
end