# frozen_string_literal: true

require 'bcrypt'
require 'rom'
require 'rom-sql'
require 'sinatra/base'
require_relative 'app/api/v1'
require_relative 'app/concepts/user'
require_relative 'app/env'

module Sanchin
  # The Sanchin Power Application.
  class App < Sinatra::Base
    Env.load

    configure do
      # Sinatra settings
      enable :logging if settings.development? or settings.production?
      set :show_exceptions, :after_handler if settings.development?
      # A common idiom is to set the :root setting explicitly in the main
      # application file
      set :root, File.dirname(__FILE__)

      # Set the bcrypt cost to be used on this machine.
      BCrypt::Engine.cost = ENV['BCRYPT_COST'].to_i

      # Ruby Object Mapper setup
      config = ROM::Configuration.new(:sql, ENV['DATABASE_URL'])
      config.register_relation(UserConcept::Relation)
      container = ROM.container(config)
      set :repositories,
          users: UserConcept::Repository.new(container)
    end

    use API::VersionOne

    # start the server if we are executed directly.
    run! if app_file == $PROGRAM_NAME
  end
end
