# frozen_string_literal: true

require 'bcrypt'
require 'json'
require 'rack-request-id'
require 'request_store'
require 'rom'
require 'rom-sql'
require 'sinatra/base'
require 'sinatra/json'
require_relative 'app/concepts/user'
require_relative 'lib/env'

module Sanchin
  # The Sanchin Power Application.
  class App < Sinatra::Base
    use Rack::RequestId, storage: RequestStore

    configure do
      Env.load
      # Sinatra settings
      enable :logging if settings.development? or settings.production?
      set :show_exceptions, :after_handler if settings.development?
      disable :static
      # A common idiom is to set the :root setting explicitly in the main
      # application file
      set :root, File.dirname(__FILE__)

      # Set the bcrypt cost to be used on this machine.
      BCrypt::Engine.cost = ENV['BCRYPT_COST'].to_i

      # Ruby Object Mapper setup
      config = ROM::Configuration.new(:sql, ENV['DATABASE_URL'])
      config.register_relation(UserConcept::Relation)
      container = ROM.container(config)
      set :user_repo, UserConcept::Repository.new(container)
    end

    helpers do
      # The request body as JSON, halt with "400 Bad Request" on parsing
      # failure.
      def json_body
        body = request.body
        body.rewind
        JSON.parse body.read
      rescue JSON::ParserError
        status :bad_request
        halt json(error: 'failed to parse the request body as JSON')
      end
    end

    before do
      # Custom Logger format so that we can add the request id,
      # see https://github.com/sinatra/sinatra/issues/1219
      logger.formatter = proc do |severity, datetime, _, msg|
        reqid = RequestStore[:request_id]
        "[#{datetime.iso8601 3} #{reqid} #{severity}] #{msg}\n"
      end
      # Disable caching so that clients are forced to re-validate any resource.
      cache_control :no_cache
    end

    # heartbeat end-point.
    get '/api/v1/ping' do
      json answer: 'pong'
    end

    # User creation end-point.
    post '/api/v1/users' do
      operation = UserConcept::Operation::Create
      result = operation.call(payload: json_body, user_repo: settings.user_repo)
      if result.success?
        status :created
        json result[:presentable]
      else
        status :bad_request
        json result[:validation].errors
      end
    end
  end
end
