class RemoveCommitHashFromInitialLabCommit < ActiveRecord::Migration
  def up
    remove_column :lab_descriptions, :commit_hash
  end

  def down
    add_column :lab_descriptions, :commit_hash, default: :string
  end
end
