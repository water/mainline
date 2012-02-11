class IdentToIdentification < ActiveRecord::Migration
  def self.up
    rename_column :lab_groups, :ident, :identification
  end

  def self.down
    rename_column :lab_groups, :identification, :ident
  end
end
