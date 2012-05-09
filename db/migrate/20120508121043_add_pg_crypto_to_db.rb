class AddPgCryptoToDb < ActiveRecord::Migration
  def change
    config = YAML::load_file(File.join(Rails.root,"config/database.yml"))[Rails.env]
    `psql -U #{config["username"]} -d #{config["database"]} -f #{File.join(Rails.root,"db/pgcrypto.sql")}`
  end
end
