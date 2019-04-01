# frozen_string_literal: true

ROM::SQL.migration do
  up do
    run <<-'SQL'
      CREATE TABLE users (
        id uuid NOT NULL DEFAULT gen_random_uuid(),
        created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
        login character varying(255) DEFAULT NULL,
        password bcrypthash DEFAULT NULL,
        firstname character varying(255) NOT NULL,
        lastname character varying(255) NOT NULL,
        birthdate date NOT NULL,
        gender gender DEFAULT NULL,

        PRIMARY KEY (id),
        CONSTRAINT updated_at_gte_created_at CHECK (updated_at >= created_at),
        UNIQUE (login)
      );
    SQL
    run <<-'SQL'
      CREATE TRIGGER trigger_updated_at
      BEFORE UPDATE ON users
      FOR EACH ROW EXECUTE PROCEDURE set_updated_at();
    SQL
  end

  down do
    run 'DROP TRIGGER IF EXISTS trigger_updated_at ON users'
    run 'DROP TABLE IF EXISTS users'
  end
end
