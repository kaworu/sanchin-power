# frozen_string_literal: true

require 'app/app'

describe Sanchin::App do
  subject { described_class.new(root: APP_ROOT) }

  describe '#root' do
    it 'should be APP_ROOT' do
      expect(subject.root).to be APP_ROOT
    end
  end

  describe '#config' do
    it 'should be the Config' do
      expect(subject.config).to be_a(Sanchin::Config)
    end
  end

  describe '#env' do
    it 'should be :test' do
      expect(subject.env).to be_a(Symbol).and eq(:test)
    end
  end

  describe '#configure' do
    it 'should run when the current env is provided' do
      expect do |b|
        subject.configure(subject.env, &b)
      end.to yield_control.exactly(1).times
    end
    it 'should not run when another env than the current one is provided' do
      expect { |b| subject.configure(:foo, &b) }.not_to yield_control
    end
  end
end
