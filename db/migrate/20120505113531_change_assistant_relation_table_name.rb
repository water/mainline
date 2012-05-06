class ChangeAssistantRelationTableName < ActiveRecord::Migration
  def up
    rename_table :assistant_registered_to_given_courses_lab_has_groups, :assistant_registered_to_given_course_has_lab_has_groups
  end

  def down
    rename_table :assistant_registered_to_given_course_has_lab_has_groups, :assistant_registered_to_given_courses_lab_has_groups
  end
end
