# frozen_string_literal: true

module Sanchin
  # Some commonly used Regexp.
  module Regexp
    UUID_V4 = /^[0-9A-F]{8}-[0-9A-F]{4}-4[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}$/i.freeze
    BCRYPT_HASH = /^\$[0-9a-z]{2}\$[0-9]{2}\$[A-Za-z0-9./]{53}$/.freeze
  end
end
