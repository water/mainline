class RenameAssistantRegisteredForeignKeys < ActiveRecord::Migration
  def up
    rename_column :lab_has_registered_assistants, :assistant_registered_to_given_course_id, :assistant_registered_for_course_id
    rename_column :assistant_registered_for_courses_has_lab_has_groups, :assistant_registered_to_given_course_id, :assistant_registered_for_course_id
  end

  def down
    rename_column :lab_has_registered_assistants, :assistant_registered_for_course_id, :assistant_registered_to_given_course_id
    rename_column :assistant_registered_for_courses_has_lab_has_groups, :assistant_registered_for_course_id, :assistant_registered_to_given_course_id
  end
end
