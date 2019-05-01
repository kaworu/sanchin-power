# frozen_string_literal: true

require 'sequel'

module Sanchin
  # A user of the system.
  class User < Sequel::Model
    # hide the password from the JSON output.
    def to_json(options = {})
      options[:except] = (options[:except] || []).concat([:password])
      super options
    end
  end
end
