class RenameAssistantRegisteredToGivenCourseToAssistantRegisteredForCourse < ActiveRecord::Migration
  def change
    rename_table :assistant_registered_to_given_courses, :assistant_registered_for_courses 
    rename_table :assistant_registered_to_given_course_has_lab_has_groups, :assistant_registered_for_courses_has_lab_has_groups
  end
end
