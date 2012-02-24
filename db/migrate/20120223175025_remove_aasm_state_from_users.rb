class RemoveAasmStateFromUsers < ActiveRecord::Migration
  def self.up
    remove_column :users, :aasm_state
  end

  def self.down
    add_column :users, :aasm_state, :string
  end
end
