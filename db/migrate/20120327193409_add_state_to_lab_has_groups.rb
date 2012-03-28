class AddStateToLabHasGroups < ActiveRecord::Migration
  def change
    add_column :lab_has_groups, :state, :string

  end
end
