# frozen_string_literal: true

module Sanchin
  module APIv1
    # Sinatra helpers for the Sanchin API.
    module Help
      # Return 415 if the request content-type is not JSON.
      def application_json_content_type
        return if request.content_type == 'application/json'

        status :unsupported_media_type
        halt
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

      # the DateTime found in the if-unmodified-since http header, halt with
      # "428 Precondition Required" if the header could not be parsed as
      # HTTP-date and "412 Precondition Failed" if the header was not provided.
      def http_if_unmodified_since
        unless (since = request.env['HTTP_IF_UNMODIFIED_SINCE'])
          status :precondition_required
          halt
        end
        DateTime.httpdate(since)
      rescue ArgumentError
        status :precondition_failed
        halt
      end

      # TODO
      def current_user
        nil
      end
    end
  end
end
