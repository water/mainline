class AddNotesToSubmission < ActiveRecord::Migration
  def change
    add_column :submissions, :notes, :string

  end
end
