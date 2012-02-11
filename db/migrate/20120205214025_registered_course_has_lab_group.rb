class RegisteredCourseHasLabGroup < ActiveRecord::Migration
  def self.up
    create_table :registered_course_has_lab_groups, id: false do |t|
      t.integer :registered_course_id
      t.integer :lab_group_id
    end
    
    add_index :registered_course_has_lab_groups, :registered_course_id
    add_index :registered_course_has_lab_groups, :lab_group_id
  end

  def self.down
    drop_table :registered_course_has_lab_groups
  end
end
