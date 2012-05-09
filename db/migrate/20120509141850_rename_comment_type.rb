class RenameCommentType < ActiveRecord::Migration
  def up
      rename_column :comments, :type, :kind
  end

  def down
  end
end
