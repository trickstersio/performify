require 'spec_helper'

RSpec.describe Performify::Base do
  after { described_class.clean_callbacks }

  let(:user) { double(:user) }
  let(:args) do
    {
      foo: 'bar'
    }
  end

  subject { described_class.new(user, **args) }

  describe '#initialize' do
    it 'accepts current user' do
      expect(subject.current_user).to eq(user)
    end

    it 'accept additional args and creates getters for it' do
      expect(subject.foo).to eq(args[:foo])
    end
  end
end
