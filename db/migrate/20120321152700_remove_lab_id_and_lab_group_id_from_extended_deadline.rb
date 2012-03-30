class RemoveLabIdAndLabGroupIdFromExtendedDeadline < ActiveRecord::Migration
  def up
    remove_column :extended_deadlines, :lab_id
    remove_column :extended_deadlines, :lab_group_id
  end

  def down
    add_column :extended_deadlines, :lab_id, :integer
    add_column :extended_deadlines, :lab_group_id, :integer
  end
end
