class AddGivenCourseIdToLabGroups < ActiveRecord::Migration
  def change
    add_column :lab_groups, :given_course_id, :integer
  end
end
