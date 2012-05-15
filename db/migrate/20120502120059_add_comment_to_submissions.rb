class AddCommentToSubmissions < ActiveRecord::Migration
  def change
    add_column :submissions, :comment_id, :integer
  end
end
