# frozen_string_literal: true

# Ruby Logger setup,
# see https://ruby-doc.org/stdlib-2.5.0/libdoc/logger/rdoc/Logger.html
module Sanchin
  Container.boot(:logger) do |container|
    init do
      require 'logger'
    end

    start do
      use :environment
      output = (ENV['APP_ENV'] == 'test' ? IO::NULL : $stdout)
      logger = Logger.new(output)
      container.register(:logger, logger)
    end
  end
end
