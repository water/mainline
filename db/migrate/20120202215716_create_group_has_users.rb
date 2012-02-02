class CreateGroupHasUsers < ActiveRecord::Migration
  def self.up
    create_table :group_has_users do |t|
      t.references :Student
      t.references :LabGroup

      t.timestamps
    end
  end

  def self.down
    drop_table :group_has_users
  end
end
