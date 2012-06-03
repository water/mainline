class CorrectAssistantToLhgRelationTableName < ActiveRecord::Migration
  def up
    rename_table :assistant_registered_for_courses_has_lab_has_groups, :assistant_registered_for_course_has_lab_has_groups
  end

  def down
    rename_table :assistant_registered_for_course_has_lab_has_groups, :assistant_registered_for_courses_has_lab_has_groups
  end
end
