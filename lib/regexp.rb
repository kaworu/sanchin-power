# frozen_string_literal: true

module Sanchin
  # Some commonly used Regexp.
  module Regexp
    UUID_V4 = /^[0-9A-F]{8}-[0-9A-F]{4}-4[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}$/i.freeze
    BCRYPT_HASH = /^\$2[ayb]\$.{56}$/i.freeze
  end
end
