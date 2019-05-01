# frozen_string_literal: true

# Sequel Setup,
# see https://github.com/jeremyevans/sequel#getting-started
module Sanchin
  Container.boot(:database) do |container|
    init do
      require 'sequel'
    end

    start do
      use :environment
      use :logger
      # So that we can call to_json on our models.
      Sequel::Model.plugin :json_serializer
      # use DateTime because to_s honor ISO8601 which is convenient when
      # rendering JSON.
      Sequel.datetime_class = DateTime
      database = Sequel.connect(ENV['DATABASE_URL'], logger: logger)
      container.register(:database, database)
    end

    stop do
      database.disconnect
    end
  end
end
