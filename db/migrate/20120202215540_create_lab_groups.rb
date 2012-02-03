class CreateLabGroups < ActiveRecord::Migration
  def self.up
    create_table :lab_groups do |t|
      t.integer :ident
      t.references :RegisteredCourse

      t.timestamps
    end
  end

  def self.down
    drop_table :lab_groups
  end
end
