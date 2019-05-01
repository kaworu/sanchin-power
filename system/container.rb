# frozen_string_literal: true

require 'dry/system/container'

module Sanchin
  # Our Application Container.
  class Container < Dry::System::Container
    configure do |config|
      config.root = File.expand_path File.join(__dir__, '..')
      config.auto_register = 'app'
    end

    load_paths!('app')

    namespace 'database' do
      register 'transaction' do |input, &block|
        result = nil
        Container['database'].transaction do
          result = block.call(Dry::Monads::Success(input))
          raise Sequel::Rollback if result.failure?
        end
        result
      end
    end

    # Yield if and only if the current env is in the given targets.
    def self.environment(*targets)
      start :environment
      yield if targets.map(&:to_s).include? ENV['APP_ENV']
    end

    # @api private
    # dry-system >= 0.11.0
    # see https://github.com/dry-rb/dry-system/commit/1d4742da9da9b565e1bb0488052210707f127be8
    def self.shutdown!
      booter.components.each do |component|
        stop(component.identifier)
      end
    end
  end
end
