# frozen_string_literal: true

module Sanchin
  module APIv1
    # Sinatra helpers for the Sanchin API.
    module Help
      # Halt with "415 Unsupported Media Type" if the request content-type is
      # not JSON.
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

      # the DateTime found in the if-unmodified-since http header, nil if the
      # header could not be parsed or was not provided.
      def http_if_unmodified_since
        DateTime.httpdate(request.env['HTTP_IF_UNMODIFIED_SINCE']) rescue nil
      end

      # TODO
      def current_user
        nil
      end
    end
  end
end
