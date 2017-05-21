require 'spec_helper'

RSpec.describe Performify::Base do
  let(:user) { double(:user) }
  let(:args) do
    {
      foo: 'bar'
    }
  end

  let(:klass) do
    Class.new(described_class) do
      schema do
        required(:foo).filled(:str?)
      end

      def execute!
        super { true }
      end
    end
  end

  subject { klass.new(user, **args) }

  after { klass.clean_callbacks }

  describe '#initialize' do
    it 'validates given args using defined schema without errors' do
      expect(subject.errors).to be_empty
    end

    it 'allows to successfully execute without any problems' do
      subject.execute!
      expect(subject.success?).to be true
    end

    context 'when args are invalid' do
      let(:args) do
        {
          foo: nil
        }
      end

      it 'validates given args and provides access to errors' do
        expect(subject.errors).to be_present
      end

      it 'mark execution as failed even before execution call' do
        expect(subject.fail?).to be true
      end

      it 'ignores all attempts of service execution' do
        subject.execute!
        expect(subject.success?).to be false
      end
    end
  end
end
