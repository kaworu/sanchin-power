# frozen_string_literal: true

require 'sequel'

module Sanchin
  # A user of the system.
  class User < Sequel::Model
    # hide the password from the JSON output.
    def to_json(options = {})
      # NOTE: there is incompatibility with json and Sequel JsonSerializer,
      # see https://sequel.jeremyevans.net/rdoc-plugins/classes/Sequel/Plugins/JsonSerializer.html
      super except: :password
    end

    # Overrided to return a BCrypt::Password instance if there is a password.
    def password
      password = super
      password = Container['password'].new(password) if password
      password
    end

    def password=(cleartext)
      super Container['password'].create(cleartext)
    end
  end
end
