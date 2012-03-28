class RemoveUnusedColumnsFromRepository < ActiveRecord::Migration
  def up
    remove_column :repositories, :name
    remove_column :repositories, :user_id
    remove_column :repositories, :owner_id
  end

  def down
    add_column :repositories, :name, :string
    add_column :repositories, :user_id, :integer
    add_column :repositories, :owner_id, :integer
  end
end
