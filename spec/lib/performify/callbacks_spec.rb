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

  describe '.register_callback' do
    it 'raises UnknownTypeOfCallbackError in case of unknown type of callbacks' do
      expect do
        described_class.register_callback(:unknown) { true }
      end.to raise_error(Performify::Callbacks::UnknownTypeOfCallbackError)
    end

    it 'does not raise UnknownTypeOfCallbackError in case of unknown type of callbacks' do
      expect do
        described_class.register_callback(:success) { true }
      end.not_to raise_error
    end

    it 'returns nil by default' do
      expect(described_class.register_callback(:success) { true }).to be nil
    end
  end

  describe '.execute_callbacks' do
    after { described_class.clean_callbacks }

    it 'executes callbacks of given type' do
      expect do |b|
        described_class.register_callback(:success, &b)
        described_class.register_callback(:success, &b)
        described_class.register_callback(:success, &b)

        described_class.execute_callbacks(:success, subject)
      end.to yield_control.exactly(3).times
    end

    it 'provides instance as an argument to callback' do
      expect do |b|
        described_class.register_callback(:success, &b)
        described_class.execute_callbacks(:success, subject)
      end.to yield_with_args(subject)
    end

    it 'executes callback method' do
      klass = Class.new(described_class) do
        def execute!
          super { true }
        end

        def foo; end

        on_success :foo
      end

      instance = klass.new(user)
      expect(instance).to receive(:foo)
      instance.execute!
    end
  end
end
