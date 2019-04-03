# frozen_string_literal: true

require 'sinatra/base'

module Sanchin
  module API
    # The first version of the Sanchin Power API.
    class VersionOne < Sinatra::Base
      before do
        cache_control :private, :must_revalidate, max_age: 60
      end

      get '/' do
        'Hello World'
      end
    end
  end
end
