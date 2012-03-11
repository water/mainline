class AddActiveToLabs < ActiveRecord::Migration
  def change
    add_column :labs, :active, :boolean, default: false
  end
end
