class RemoveUnusedTables < ActiveRecord::Migration
  def up
    drop_table :cloners
    drop_table :committerships
    drop_table :group_has_users
    drop_table :groups
    drop_table :memberships
    drop_table :merge_requests
    drop_table :merge_requests_statuses
    drop_table :merge_requests_versions
    drop_table :projects
    drop_table :registered_course_has_lab_groups
    drop_table :sites
    drop_table :ssh_keys
    drop_table :taggings
    drop_table :tags
  end

  def down
  end
end
