class CreateInitialLabCommitForLabs < ActiveRecord::Migration
  def change
    create_table :initial_lab_commit_for_labs, id: false do |t|
      t.integer :initial_lab_commit_id
      t.integer :lab_id
    end
  end
end
