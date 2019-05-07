# frozen_string_literal: true

# Sanchin .env setup
module Sanchin
  Container.boot(:environment) do |container|
    init do
      require 'dotenv'
      ENV['APP_ENV'] ||= 'development'
    end

    start do
      env = ENV['APP_ENV']
      specific_dotenv_path = File.join(container.root, ".env.#{env}")
      generic_dotenv_path  = File.join(container.root, '.env')
      Dotenv.load(specific_dotenv_path, generic_dotenv_path)
      Dotenv.require_keys %w[APP_ENV BCRYPT_COST DATABASE_URL JWT_SECRET]
    end
  end
end
