ROM::SQL.migration do
  up do
    run <<-'SQL'
      CREATE TYPE gender AS ENUM ('male', 'female');
    SQL
  end

  down do
    run 'DROP TYPE IF EXISTS gender'
  end
end
