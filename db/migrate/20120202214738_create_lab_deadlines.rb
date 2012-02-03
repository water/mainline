class CreateLabDeadlines < ActiveRecord::Migration
  def self.up
    create_table :lab_deadlines do |t|
      t.datetime :at
      t.references :Lab

      t.timestamps
    end
  end

  def self.down
    drop_table :lab_deadlines
  end
end
