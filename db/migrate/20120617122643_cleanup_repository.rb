class CleanupRepository < ActiveRecord::Migration
  def change
    change_table :repositories do |t|
      t.remove :project_id, :parent_id, :kind, :owner_type, :description,
        :last_pushed_at, :wiki_permissions, :deny_force_pushing,
        :notify_committers_on_new_merge_request, :last_gc_at,
        :merge_requests_enabled, :push_count_since_gc
    end
  end

end
