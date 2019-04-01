# frozen_string_literal: true

require 'app/app'

describe Sanchin::App do
  before :all do
    @app = Sanchin::App.new(root: APP_ROOT)
  end

  describe '#root' do
    it 'should be APP_ROOT' do
      expect(@app.root).to be APP_ROOT
    end
  end

  describe '#config' do
    it 'should be the Config' do
      expect(@app.config).to be_a(Sanchin::Config)
    end
  end

  describe '#env' do
    it 'should be :test' do
      expect(@app.env).to be_a(Symbol).and eq(:test)
    end
  end

  describe '#configure' do
    it 'should run when the current env is provided' do
      app = @app
      env = @app.env
      expect { |b| app.configure(env, &b) }.to yield_control.exactly(1).times
    end
    it 'should not run when another env than the current one is provided' do
      app = @app
      expect { |b| app.configure(:foo, &b) }.not_to yield_control
    end
  end
end
