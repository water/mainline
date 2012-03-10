class RenameLabDefaultDeadlineToDefaultDeadline < ActiveRecord::Migration
  def up
    rename_table :lab_default_deadlines, :default_deadlines
  end

  def down
    rename_table :default_deadlines, :lab_default_deadlines
  end
end
