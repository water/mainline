class CreateLabDefaultDeadlines < ActiveRecord::Migration
  def change
    create_table :lab_default_deadlines do |t|
      t.datetime :at
      t.integer :lab_id
      t.string :description

      t.timestamps
    end
  end
end
