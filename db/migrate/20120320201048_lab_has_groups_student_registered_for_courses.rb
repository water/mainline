class LabHasGroupsStudentRegisteredForCourses < ActiveRecord::Migration
  def up
    create_table :lab_has_groups_student_registered_for_courses, id: false do |t|
      t.integer :lab_has_group_id
      t.integer :student_registered_for_course_id
    end

    add_index :lab_has_groups_student_registered_for_courses, :lab_has_group_id, name: :lhgsrfc_lab_has_group_id
    add_index :lab_has_groups_student_registered_for_courses, :student_registered_for_course_id, name: :lhgsrfc_student_registered_for_course_id
  end

  def down
    drop_table :lab_has_groups_student_registered_for_courses
  end
end
