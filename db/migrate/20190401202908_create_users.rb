# frozen_string_literal: true

ROM::SQL.migration do
  up do
    run <<-'SQL'
      CREATE TABLE users (
        id uuid NOT NULL DEFAULT gen_random_uuid(),
        created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
        login citext DEFAULT NULL,
        password bcrypthash DEFAULT NULL,
        firstname citext NOT NULL,
        lastname citext NOT NULL,
        birthday date NOT NULL,
        gender gender DEFAULT NULL,

        PRIMARY KEY (id),
        CONSTRAINT updated_at_gte_created_at CHECK (updated_at >= created_at),
        UNIQUE (login)
      );
    SQL
    run <<-'SQL'
      CREATE OR REPLACE FUNCTION users_initcap_names()
      RETURNS TRIGGER AS $$
      BEGIN
        NEW.firstname := initcap(NEW.firstname);
        NEW.lastname  := initcap(NEW.lastname);
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;
    SQL
    run <<-'SQL'
      CREATE OR REPLACE FUNCTION users_lower_login()
      RETURNS TRIGGER AS $$
      BEGIN
        NEW.login := lower(NEW.login);
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;
    SQL
    run <<-'SQL'
      CREATE TRIGGER trigger_updated_at
      BEFORE UPDATE ON users
      FOR EACH ROW EXECUTE PROCEDURE set_updated_at();
    SQL
    run <<-'SQL'
      CREATE TRIGGER trigger_users_initcap_names
      BEFORE INSERT OR UPDATE ON users
      FOR EACH ROW EXECUTE PROCEDURE users_initcap_names();
    SQL
    run <<-'SQL'
      CREATE TRIGGER trigger_users_lower_login
      BEFORE INSERT OR UPDATE ON users
      FOR EACH ROW EXECUTE PROCEDURE users_lower_login();
    SQL
  end

  down do
    run 'DROP TRIGGER IF EXISTS trigger_users_lower_login ON users'
    run 'DROP TRIGGER IF EXISTS trigger_users_initcap_names ON users'
    run 'DROP TRIGGER IF EXISTS trigger_updated_at ON users'
    run 'DROP FUNCTION IF EXISTS users_lower_login'
    run 'DROP FUNCTION IF EXISTS users_initcap_names'
    run 'DROP TABLE IF EXISTS users'
  end
end
