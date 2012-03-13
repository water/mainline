class AddLabGroupsStudentRegisteredForCoursesRelation < ActiveRecord::Migration
  def up
    create_table :lab_groups_student_registered_for_courses, id: false do |t|
      t.integer :lab_group_id
      t.integer :student_registered_for_course_id
    end
  end

  def down
    drop_table :lab_groups_student_registered_for_courses
  end
end
