# frozen_string_literal: true

Sequel.migration do
  up do
    run <<-'SQL'
      CREATE DOMAIN version AS uuid;
    SQL
    run <<-'SQL'
      CREATE OR REPLACE FUNCTION change_version()
      RETURNS TRIGGER AS $$
      BEGIN
        NEW.version := gen_random_uuid();
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;
    SQL
  end

  down do
    run 'DROP FUNCTION IF EXISTS change_version'
    run 'DROP DOMAIN IF EXISTS version'
  end
end
