class RenameRegisteredCourseToStudentForRegisteredCourse < ActiveRecord::Migration
  def up
    rename_table :student_registered_for_courses, :student_registered_for_courses
  end

  def down
    rename_table :student_registered_for_courses, :student_registered_for_courses
  end
end
