# frozen_string_literal: true

module Sanchin
  module APIv1
    # Very simple app providing a single entry point to query the app status.
    class Heartbeat < Base
      # heartbeat end-point.
      get '/api/v1/ping' do
        json answer: 'pong'
      end
    end
  end
end
