# frozen_string_literal: true

require 'rack-request-id'
require 'request_store'
require 'sinatra/base'
require 'sinatra/custom_logger'
require 'sinatra/json'

module Sanchin
  module APIv1
    # Base class for all the API stuff. Handle most sinatra configuration and
    # helpers.
    class Base < Sinatra::Base
      use Rack::RequestId, storage: RequestStore

      helpers Help

      # Sinatra settings
      configure do
        # A common idiom is to set the :root setting explicitly in the main
        # application file
        set :root, Container.root
        disable :static
        set :show_exceptions, :after_handler if settings.development?
        # Make Sinatra use our logger.
        enable :logging
        set :logger, Container['logger']
        # Custom Logger format so that we can add the request id,
        # see https://github.com/sinatra/sinatra/issues/1219
        logger.formatter = proc do |severity, datetime, _, msg|
          reqid = RequestStore[:request_id]
          "[#{datetime.iso8601 3} #{reqid} #{severity}] #{msg}\n"
        end
      end

      before do
        # Disable caching so that clients are forced to re-validate any resource.
        cache_control :no_cache
      end

      # authorization Bearer authentication filter.
      # set @current_user when the token is valid, halt if required.
      set :authenticated do |required|
        condition do
          token = bearer_auth
          transaction = UserConcept::Transactions::Authenticate.new
          transaction.call(token) do |on|
            on.success do |user|
              @current_user = user
            end
            on.failure do
              if required
                status :unauthorized
                response.headers['WWW-Authenticate'] = 'Bearer'
                halt
              end
            end
          end
        end
      end
    end
  end
end
