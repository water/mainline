class AddDescriptionIdToLabs < ActiveRecord::Migration
  def change
    add_column :labs, :description_id, :integer

  end
end
