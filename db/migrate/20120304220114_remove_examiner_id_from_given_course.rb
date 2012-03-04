class RemoveExaminerIdFromGivenCourse < ActiveRecord::Migration
  def up
    remove_column :given_courses, :examiner_id
  end

  def down
    add_column :given_courses, :examiner_id, :integer
  end
end
