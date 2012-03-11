class CreateExtendedDeadlines < ActiveRecord::Migration
  def change
    create_table :extended_deadlines do |t|
      t.integer :lab_id
      t.integer :group_id
      t.datetime :at

      t.timestamps
    end
  end
end
