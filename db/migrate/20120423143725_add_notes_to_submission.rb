class AddNotesToSubmission < ActiveRecord::Migration
  def change
    add_column :submissions, :notes, :text

  end
end
