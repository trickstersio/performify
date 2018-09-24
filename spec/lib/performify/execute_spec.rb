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

  describe '#execute!' do
    it 'calls given block' do
      expect { |b| subject.execute!(&b) }.to yield_control
    end

    it 'returns result of given block execution' do
      expect(subject.execute! { :foo }).to eq(:foo)
    end

    it 'calls registered success callback when execution was successfull' do
      expect do |b|
        described_class.register_callback(:success, &b)
        subject.execute! { true }
      end.to yield_with_args(subject)
    end

    it 'does not call registered success callback when execution was failed' do
      expect do |b|
        described_class.register_callback(:success, &b)
        subject.execute! { false }
      end.not_to yield_control
    end

    it 'does not call registered fail callback when execution was successfull' do
      expect do |b|
        described_class.register_callback(:fail, &b)
        subject.execute! { true }
      end.not_to yield_control
    end

    it 'calls registered fail callback when execution was failed' do
      expect do |b|
        described_class.register_callback(:fail, &b)
        subject.execute! { false }
      end.to yield_control
    end

    context 'when execution raises ActiveRecord::RecordInvalid' do
      it 'calls registered fail callback only once' do
        expect do |b|
          described_class.register_callback(:fail, &b)
          subject.execute! { raise ActiveRecord::RecordInvalid }
        end.to yield_control.once
      end
    end

    context 'when execution has been already performed' do
      it 'performes execution only once' do
        expect do |b|
          subject.execute!(&b)
        end.to yield_control.exactly(1).times
      end
    end

    context 'when execution result is already known' do
      it 'does not perform execution' do
        subject.fail!(with_callbacks: false)
        expect { |b| subject.execute!(&b) }.to yield_control.exactly(0).times
      end
    end
  end

  describe '#success!' do
    it 'calls registered success callback' do
      expect do |b|
        described_class.register_callback(:success, &b)
        subject.success!
      end.to yield_with_args(subject)
    end

    it 'does not call registered fail callback' do
      expect do |b|
        described_class.register_callback(:fail, &b)
        subject.success!
      end.not_to yield_control
    end
  end

  describe '#fail!' do
    it 'calls registered fail callback' do
      expect do |b|
        described_class.register_callback(:fail, &b)
        subject.fail!
      end.to yield_control
    end

    it 'does not call registered success callback' do
      expect do |b|
        described_class.register_callback(:success, &b)
        subject.fail!
      end.not_to yield_control
    end

    it 'stores provided errors' do
      errors = { foo: 'bar' }
      subject.fail!(errors: errors)
      expect(subject.errors).to eq(errors)
    end
  end

  describe '#success?' do
    it 'returns true when execution was successful' do
      subject.execute! { true }
      expect(subject.success?).to be true
    end

    it 'returns false when execution was failed' do
      subject.execute! { false }
      expect(subject.success?).to be false
    end
  end

  describe '#fail?' do
    it 'returns false when execution was successful' do
      subject.execute! { true }
      expect(subject.fail?).to be false
    end

    it 'returns true when execution was failed' do
      subject.execute! { false }
      expect(subject.fail?).to be true
    end
  end
end
