class CreateLabs < ActiveRecord::Migration
  def self.up
    create_table :labs do |t|
      t.integer :number
      t.integer :lab_commit_id
      t.references :GivenCourse
      t.references :LabDescription

      t.timestamps
    end
  end

  def self.down
    drop_table :labs
  end
end
