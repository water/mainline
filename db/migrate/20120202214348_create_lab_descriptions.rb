class CreateLabDescriptions < ActiveRecord::Migration
  def self.up
    create_table :lab_descriptions do |t|
      t.string :description
      t.string :title
      t.references :When

      t.timestamps
    end
  end

  def self.down
    drop_table :lab_descriptions
  end
end
