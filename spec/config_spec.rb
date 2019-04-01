# frozen_string_literal: true

require 'app/config'

describe Sanchin::Config do
  before :all do
    @config = Sanchin::Config.new(root: APP_ROOT)
  end

  describe '#env' do
    it 'should be :test' do
      expect(@config.env).to be_a(Symbol).and eq(:test)
    end
  end

  describe '#default_env' do
    it 'should be :development' do
      expect(@config.send(:default_env)).to be_a(Symbol).and eq(:development)
    end
  end

  describe '#bcrypt_cost' do
    it 'should be greater than four' do
      expect(@config.bcrypt_cost).to be_a(Integer).and be >= 4
    end
  end

  describe '#database_url' do
    it 'should be postgres' do
      expect(@config.database_url).to match(%r{^postgres://})
    end
  end
end
