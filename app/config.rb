# frozen_string_literal: true
require 'dotenv'

module Sanchin
  # Sanchin Power Configuration handler.
  class Config
    # Load a new configuration given the project's root path.
    def initialize(root:)
      @root = root
      load
    end

    # The loaded environment.
    def env
      (ENV['APP_ENV'] || default_env).to_sym
    end

    # The BCrypt::Engine.cost that should be used.
    def bcrypt_cost
      ENV['BCRYPT_COST'].to_i
    end

    # The default SQL Database Data Source Name.
    def database_url
      ENV['DATABASE_URL']
    end

    # ROM::Configuration auto_registration path.
    # see ROM::Configuration
    def rom_path
      File.join(@root, 'db')
    end

    protected

    # Load the configured settings for the requested environment into ENV.
    def load
      Dotenv.load(local_dotenv_path, global_dotenv_path)
      Dotenv.require_keys('DATABASE_URL', 'BCRYPT_COST')
    end

    # The project's .env file path that should be used regardless of the
    # requested environment.
    def global_dotenv_path
      dotenv_path('.env')
    end

    # The project's .env file path that should be used for the requested
    # environment.
    def local_dotenv_path
      dotenv_path(".env.#{env}")
    end

    # The expanded path of the given file with respect to the root directory.
    def dotenv_path(file)
      File.expand_path File.join(@root, file)
    end

    # The environment that should be used when none is set in APP_ENV.
    def default_env
      :development
    end
  end
end
