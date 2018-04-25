require 'spec_helper'

RSpec.describe Performify::Base do
  after { described_class.clean_callbacks }

  let(:user) { double(:user) }
  let(:args) do
    {
      foo: 'bar'
    }
  end

  subject { described_class.new(user, args) }

  describe '#initialize' do
    it 'accepts current user' do
      expect(subject.current_user).to eq(user)
    end

    it 'accepts args' do
      expect(subject.args).to eq(args)
    end

    it 'accept additional args and creates getters for it' do
      expect(subject.foo).to eq(args[:foo])
    end

    it 'no filtered inputs' do
      expect(subject.inputs).to be_nil
    end

    context 'when we pass args as keyword arguments' do
      subject { described_class.new(user, **args) }

      it 'still works fine' do
        expect(subject.foo).to eq(args[:foo])
      end

      it 'no filtered inputs' do
        expect(subject.inputs).to be_nil
      end
    end

    context 'with defined schema' do
      subject { klass.new(user, args) }
      after { klass.clean_callbacks }

      let(:klass) do
        Class.new(described_class) do
          schema do
            required(:foo).filled(:str?)
            optional(:baz).filled(:str?)
          end

          def execute!
            super { true }
          end
        end
      end

      it 'creates getters for required params' do
        expect(subject.foo).to eq 'bar'
      end

      it 'creates getters for optional params' do
        expect(subject.baz).to be_nil
      end

      it 'has filtered inputs' do
        expect(subject.inputs).to eq(args)
      end

      context 'when no params provided' do
        let(:args) do
          {}
        end

        it 'defines getters anyway' do
          expect(subject.foo).to be nil
        end

        it 'fails' do
          expect(subject.errors?).to be true
        end

        it 'no filtered inputs' do
          expect(subject.inputs).to be_nil
        end
      end

      context 'with params that are not in schema' do
        let(:args) do
          {
            foo: 'bar',
            qux: 'quux'
          }
        end

        it 'does not create getters for not defined params' do
          expect { subject.qux }.to raise_error(NoMethodError)
        end

        it 'has only valid filtered inputs' do
          expect(subject.inputs).to eq({ foo: 'bar' })
        end
      end
    end
  end
end
