# frozen_string_literal: true

ROM::SQL.migration do
  up do
    run <<-'SQL'
      CREATE DOMAIN bcrypthash AS character varying(60)
        CHECK (value ~ '^\$2[ayb]\$.{56}$');
    SQL
  end

  down do
    run 'DROP DOMAIN IF EXISTS bcrypthash'
  end
end
