class CreateInitialLabCommits < ActiveRecord::Migration
  def self.up
    create_table :initial_lab_commits do |t|
      t.string :commit_hash
      t.references :Repository

      t.timestamps
    end
  end

  def self.down
    drop_table :initial_lab_commits
  end
end
