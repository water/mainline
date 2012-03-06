class AssistantHasLabHasGroup < ActiveRecord::Migration
  def up
    create_table :assistant_registered_to_given_courses_lab_has_groups, id: false do |t|
      t.integer :assistant_registered_to_given_course_id
      t.integer :lab_has_group_id
    end
  end

  def down
  end
end
