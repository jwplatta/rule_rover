require 'spec_helper'

describe MyKen::VERSION do
  it 'returns current version' do
    expect(subject).to eq '0.1.0'
  end
end