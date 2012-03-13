class RemoveDuplicateLabDescriptionKeyFromLabs < ActiveRecord::Migration
  def up
    remove_column :labs, :description_id
  end

  def down
    add_column :labs, :description_id, :integer
  end
end
