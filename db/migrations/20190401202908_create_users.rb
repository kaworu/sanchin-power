# frozen_string_literal: true

Sequel.migration do
  up do
    run Query.users_table
    run Query.users_initcap_names_fn
    run Query.users_lower_login_fn
    run Query.trigger_change_version
    run Query.trigger_updated_at
    run Query.trigger_users_initcap_names
    run Query.trigger_users_lower_login
  end

  down do
    run Query.drop_trigger_users_lower_login
    run Query.drop_trigger_users_initcap_names
    run Query.drop_trigger_updated_at
    run Query.drop_trigger_change_version
    run Query.drop_users_lower_login_fn
    run Query.drop_users_initcap_names_fn
    run Query.drop_users_table
  end
end

# Migration SQL queries.
module Query
  def self.users_table
    <<-'SQL'
      CREATE TABLE users (
        id uuid NOT NULL DEFAULT gen_random_uuid(),
        version version NOT NULL,
        created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
        login citext DEFAULT NULL,
        password bcrypthash DEFAULT NULL,
        firstname citext NOT NULL,
        lastname citext NOT NULL,
        birthdate date NOT NULL,
        gender gender DEFAULT NULL,

        PRIMARY KEY (id),
        CONSTRAINT ordered_timestamps CHECK (created_at <= updated_at AND updated_at <= CURRENT_TIMESTAMP),
        UNIQUE (login),
        CONSTRAINT login_min_length CHECK (login IS NULL OR length(login) >= 3),
        CONSTRAINT both_login_and_password_or_none CHECK (login IS NOT NULL AND password IS NOT NULL OR login IS NULL AND password IS NULL),
        CONSTRAINT non_empty_names CHECK (firstname <> '' AND lastname <> ''),
        CONSTRAINT birthdate_in_the_past CHECK (birthdate <= CURRENT_DATE)
      );
    SQL
  end

  def self.drop_users_table
    'DROP TABLE IF EXISTS users'
  end

  def self.users_initcap_names_fn
    <<-'SQL'
      CREATE OR REPLACE FUNCTION users_initcap_names()
        RETURNS TRIGGER AS $$
        BEGIN
          NEW.firstname := initcap(NEW.firstname);
          NEW.lastname  := initcap(NEW.lastname);
          RETURN NEW;
        END;
      $$ LANGUAGE plpgsql;
    SQL
  end

  def self.drop_users_initcap_names_fn
    'DROP FUNCTION IF EXISTS users_initcap_names'
  end

  def self.users_lower_login_fn
    <<-'SQL'
      CREATE OR REPLACE FUNCTION users_lower_login()
      RETURNS TRIGGER AS $$
      BEGIN
        NEW.login := lower(NEW.login);
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;
    SQL
  end

  def self.drop_users_lower_login_fn
    'DROP FUNCTION IF EXISTS users_lower_login'
  end

  def self.trigger_change_version
    <<-'SQL'
      CREATE TRIGGER trigger_change_version
      BEFORE INSERT OR UPDATE ON users
      FOR EACH ROW EXECUTE PROCEDURE change_version();
    SQL
  end

  def self.drop_trigger_change_version
    'DROP TRIGGER IF EXISTS trigger_change_version ON users'
  end

  def self.trigger_updated_at
    <<-'SQL'
      CREATE TRIGGER trigger_updated_at
      BEFORE UPDATE ON users
      FOR EACH ROW EXECUTE PROCEDURE set_updated_at();
    SQL
  end

  def self.drop_trigger_updated_at
    'DROP TRIGGER IF EXISTS trigger_updated_at ON users'
  end

  def self.trigger_users_initcap_names
    <<-'SQL'
      CREATE TRIGGER trigger_users_initcap_names
      BEFORE INSERT OR UPDATE ON users
      FOR EACH ROW EXECUTE PROCEDURE users_initcap_names();
    SQL
  end

  def self.drop_trigger_users_initcap_names
    'DROP TRIGGER IF EXISTS trigger_users_initcap_names ON users'
  end

  def self.trigger_users_lower_login
    <<-'SQL'
      CREATE TRIGGER trigger_users_lower_login
      BEFORE INSERT OR UPDATE ON users
      FOR EACH ROW EXECUTE PROCEDURE users_lower_login();
    SQL
  end

  def self.drop_trigger_users_lower_login
    'DROP TRIGGER IF EXISTS trigger_users_lower_login ON users'
  end
end
