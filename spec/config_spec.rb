# frozen_string_literal: true

require 'app/config'

describe Sanchin::Config do
  subject { described_class.new(root: APP_ROOT) }

  describe '#root' do
    it 'should be APP_ROOT' do
      expect(subject.root).to be APP_ROOT
    end
  end

  describe '#env' do
    it 'should be :test' do
      expect(subject.env).to be_a(Symbol).and eq(:test)
    end
  end

  describe '#default_env' do
    it 'should be :development' do
      expect(subject.send(:default_env)).to be_a(Symbol).and eq(:development)
    end
  end

  describe '#bcrypt_cost' do
    it 'should be greater than four' do
      expect(subject.bcrypt_cost).to be_a(Integer).and be >= 4
    end
  end

  describe '#database_url' do
    it 'should be postgres' do
      expect(subject.database_url).to match(%r{^postgres://})
    end
  end

  describe '#rom_path' do
    it 'should be db/' do
      expect(subject.rom_path).to eq("#{APP_ROOT}/db")
    end
  end
end
