# frozen_string_literal: true

namespace :random do
  # Generate a given count of secure random bytes and display them as hex.
  desc 'generate count bytes of secure random data'
  task :hex, [:count] do |_, args|
    require 'securerandom'
    count = args[:count] || 16
    puts SecureRandom.hex(count.to_i)
  end
end
