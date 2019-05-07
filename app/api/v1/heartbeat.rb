# frozen_string_literal: true

require 'api/v1/base'

module Sanchin
  module APIv1
    # Very simple app providing a single entry point to query the app status.
    class Heartbeat < Base
      # heartbeat end-point.
      get '/api/v1/ping', authenticated: false do
        json answer: 'pong'
      end
    end
  end
end
