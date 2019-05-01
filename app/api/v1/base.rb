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

      helpers do
        # Return 400 if the request content-type is not JSON.
        def application_json_content_type
          return true if request.content_type == 'application/json'

          status :bad_request
          halt json(error: 'expected application/json as content-type')
        end

        # The request body as JSON, halt with "400 Bad Request" on parsing
        # failure.
        def json_body
          application_json_content_type
          body = request.body
          body.rewind
          JSON.parse body.read
        rescue JSON::ParserError
          status :bad_request
          halt json(error: 'failed to parse the request body as JSON')
        end

        # the DateTime found in the if-unmodified-since http header or nil.
        def http_if_unmodified_since
          if_unmodified_since = request.env['HTTP_IF_UNMODIFIED_SINCE']
          return nil unless if_unmodified_since

          DateTime.httpdate(if_unmodified_since)
        rescue ArgumentError
          status :bad_request
          halt json(error: 'expected HTTP-date as if-unmodified-since')
        end

        # TODO
        def current_user
          nil
        end
      end
    end
  end
end
