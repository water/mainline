class RenameRepoIdInLabHasGroups < ActiveRecord::Migration
  def up
    rename_column :lab_has_groups, :repo_id, :repository_id
  end

  def down
    rename_column :lab_has_groups, :repository_id, :repo_id
  end
end
