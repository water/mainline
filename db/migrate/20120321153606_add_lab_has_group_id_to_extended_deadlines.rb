class AddLabHasGroupIdToExtendedDeadlines < ActiveRecord::Migration
  def up
    add_column :extended_deadlines, :lab_has_group_id, :integer
  end

  def down
    remove_column :extended_deadlines, :lab_has_group_id
  end
end
