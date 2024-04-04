require 'spec_helper'

describe RuleRover::PropositionalLogic do
  describe 'connectives' do
    it 'imports connectives' do
      expect(RuleRover::PropositionalLogic::CONNECTIVES).to match_array([:and, :or, :iff, :then])
    end
  end

  describe 'operators' do
    it 'includes negation' do
      expect(RuleRover::PropositionalLogic::OPERATORS).to match_array([:and, :or, :then, :not, :iff])
    end
  end
end