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

    # updated_at trimmed at the second granularity.
    def last_update
      DateTime.iso8601(updated_at.iso8601)
    end
  end
end
