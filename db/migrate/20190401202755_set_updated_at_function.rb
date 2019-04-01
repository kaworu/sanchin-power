ROM::SQL.migration do
  up do
    run <<-'SQL'
      CREATE OR REPLACE FUNCTION set_updated_at()
      RETURNS TRIGGER AS $$
      BEGIN
        NEW.updated_at := CURRENT_TIMESTAMP;
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;
    SQL
  end

  down do
    run 'DROP FUNCTION IF EXISTS set_updated_at'
  end
end
