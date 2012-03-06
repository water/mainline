class AddCommitHashToLabDescriptions < ActiveRecord::Migration
  def change
    add_column :lab_descriptions, :commit_hash, :string

  end
end
