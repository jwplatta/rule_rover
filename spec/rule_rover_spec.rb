require 'spec_helper'

describe RuleRover do
  describe '.knowledge_base' do
    it 'does not raise' do
      expect { RuleRover.knowledge_base { } }.not_to raise_error
    end
  end
end