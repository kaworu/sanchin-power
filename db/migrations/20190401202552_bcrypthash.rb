# frozen_string_literal: true

Sequel.migration do
  up do
    run <<-'SQL'
      CREATE DOMAIN bcrypthash AS character varying(60)
        CHECK (value ~ '^\$[0-9a-z]{2}\$[0-9]{2}\$[A-Za-z0-9./]{53}$');
    SQL
  end

  down do
    run 'DROP DOMAIN IF EXISTS bcrypthash'
  end
end
