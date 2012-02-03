class CreateLabHasGroups < ActiveRecord::Migration
  def self.up
    create_table :lab_has_groups do |t|
      t.references :Lab
      t.references :LabGroup

      t.timestamps
    end
  end

  def self.down
    drop_table :lab_has_groups
  end
end
