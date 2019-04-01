# frozen_string_literal: true

ROM::SQL.migration do
  up do
    run <<-'SQL'
      CREATE DOMAIN email AS citext
        CHECK (value ~ '^[a-zA-Z0-9.!#$%&''*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$');
    SQL
  end

  down do
    run 'DROP DOMAIN IF EXISTS email'
  end
end
