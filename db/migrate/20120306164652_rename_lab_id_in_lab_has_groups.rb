class RenameLabIdInLabHasGroups < ActiveRecord::Migration
  def up
    rename_column :lab_has_groups, :Lab_id, :lab_id
  end

  def down
    rename_column :lab_has_groups, :lab_id, :Lab_id
  end
end
