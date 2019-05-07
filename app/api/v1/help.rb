# frozen_string_literal: true

require 'base64'

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

      def if_match_version
        quoted = request.env['HTTP_IF_MATCH'] || ''
        quoted[/"(.+)"/, 1]
      end

      # the [username, password] found in the authorization http header, nil if
      # the header was not provided or could not be parsed.
      def basic_auth
        auth = request.env['HTTP_AUTHORIZATION'] || ''
        encoded = auth[%r{^\s*Basic ([A-Za-z0-9+/=]+)$}, 1]
        Base64.strict_decode64(encoded).split(/:/, 2) rescue nil
      end

      # the Bearer token found in the authorization http header, nil if the
      # header was not provided or could not be parsed.
      def bearer_auth
        auth = request.env['HTTP_AUTHORIZATION'] || ''
        auth[/^\s*Bearer (.+)$/, 1]
      end
    end
  end
end
