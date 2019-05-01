# frozen_string_literal: true

context 'when the environment is started' do
  before :all do
    Sanchin::Container.start :environment
  end

  describe "ENV['APP_ENV']" do
    it 'should be test' do
      expect(ENV['APP_ENV']).to eq('test')
    end
  end

  describe Sanchin::Container do
    describe '.environment' do
      context 'when given the current env as a String' do
        it 'should yield' do
          expect do |block|
            Sanchin::Container.environment('test', &block)
          end.to yield_control.exactly(1).times
        end
        context 'when given the current env as a Symbol' do
          it 'should yield' do
            expect do |block|
              Sanchin::Container.environment(:test, &block)
            end.to yield_control.exactly(1).times
          end
        end
        context 'when given many env, including the current one' do
          it 'should yield' do
            expect do |block|
              Sanchin::Container.environment(:test, :development, &block)
            end.to yield_control.exactly(1).times
          end
        end
        context 'when given the another env' do
          it 'should not yield' do
            expect do |block|
              Sanchin::Container.environment(:production, &block)
            end.not_to yield_control
          end
        end
      end
    end
  end
end
