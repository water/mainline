class CorrectFkInExtendedDeadline < ActiveRecord::Migration
  def up
    rename_column :extended_deadlines, :group_id, :lab_group_id
  end

  def down
    rename_column :extended_deadlines, :lab_group_id, :group_id
  end
end
