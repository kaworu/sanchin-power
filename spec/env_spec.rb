# frozen_string_literal: true

require 'app/env'

describe Sanchin::Env do
  before(:context) do
    Sanchin::Env.load
  end

  describe '.default' do
    it 'should be development' do
      expect(Sanchin::Env.default).to eq('development')
    end
  end

  describe "ENV['APP_ENV']" do
    it 'should be test' do
      expect(ENV['APP_ENV']).to eq('test')
    end
  end

  describe '.configure' do
    context 'when given the current env as a String' do
      it 'should yield' do
        expect do |block|
          Sanchin::Env.configure('test', &block)
        end.to yield_control.exactly(1).times
      end
      context 'when given the current env as a Symbol' do
        it 'should yield' do
          expect do |block|
            Sanchin::Env.configure(:test, &block)
          end.to yield_control.exactly(1).times
        end
      end
      context 'when given many env, including the current one' do
        it 'should yield' do
          expect do |block|
            Sanchin::Env.configure(:test, :development, &block)
          end.to yield_control.exactly(1).times
        end
      end
      context 'when given the another env' do
        it 'should not yield' do
          expect do |block|
            Sanchin::Env.configure(:production, &block)
          end.not_to yield_control
        end
      end
    end
  end
end
