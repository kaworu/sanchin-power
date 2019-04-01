# frozen_string_literal: true

ROM::SQL.migration do
  up do
    run 'CREATE EXTENSION IF NOT EXISTS pgcrypto'
  end

  down do
    run 'DROP EXTENSION IF EXISTS pgcrypto'
  end
end
