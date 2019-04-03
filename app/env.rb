# frozen_string_literal: true

require 'dotenv'

module Sanchin
  # Sanchin Power Environment setup.
  module Env
    # The environment that should be used when none is set in APP_ENV.
    def self.default
      'development'
    end

    # Load the configured environment files into the global ENV.
    def self.load
      ENV['APP_ENV'] ||= default
      Dotenv.load(specific_dotenv_path, generic_dotenv_path)
      Dotenv.require_keys('APP_ENV')
      Dotenv.require_keys('BCRYPT_COST')
      Dotenv.require_keys('DATABASE_URL')
    end

    # Yield if and only if the current env is in the given targets.
    def self.configure(*targets)
      yield if targets.map(&:to_s).include? ENV['APP_ENV']
    end

    # The project's .env file path that should be used for the requested
    # environment.
    def self.specific_dotenv_path
      env = ENV['APP_ENV']
      dotenv_path(filename: ".env.#{env}")
    end

    # The project's .env file path that should be used regardless of the
    # requested environment.
    def self.generic_dotenv_path
      dotenv_path(filename: '.env')
    end

    # The expanded path of the given file with respect to the root directory.
    def self.dotenv_path(filename:)
      File.expand_path File.join(dotenv_root, filename)
    end

    # The root directory from where the .env files are going to be loaded.
    def self.dotenv_root
      File.expand_path File.join(__dir__, '..')
    end
  end
end
