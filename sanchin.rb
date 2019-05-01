# frozen_string_literal: true

require 'sinatra/base'
require_relative 'system/container'

module Sanchin
  # The Sanchin Power Application.
  class App < Sinatra::Base
    configure do
      Container.finalize!
    end

    use APIv1::Heartbeat
    use APIv1::Users
  end
end
