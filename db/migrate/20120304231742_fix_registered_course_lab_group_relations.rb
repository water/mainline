class FixRegisteredCourseLabGroupRelations < ActiveRecord::Migration
  def up
    remove_column :lab_groups, :registered_course_id
    create_table :lab_groups_registered_courses, id: false do |t|
      t.references :lab_group
      t.references :registered_course
    end
  end

  def down
    add_column :lab_groups, :registered_course_id, :integer
    drop_table :lab_groups_registered_courses
  end
end
