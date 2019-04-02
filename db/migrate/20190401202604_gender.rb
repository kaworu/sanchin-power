# frozen_string_literal: true

ROM::SQL.migration do
  up do
    run <<-'SQL'
      CREATE TYPE gender AS ENUM ('female', 'male');
    SQL
  end

  down do
    run 'DROP TYPE IF EXISTS gender'
  end
end
