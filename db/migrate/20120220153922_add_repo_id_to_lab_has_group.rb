class AddRepoIdToLabHasGroup < ActiveRecord::Migration
  def self.up
    add_column :lab_has_groups, :repo_id, :integer
  end

  def self.down
    remove_column :lab_has_groups, :repo_id
  end
end
