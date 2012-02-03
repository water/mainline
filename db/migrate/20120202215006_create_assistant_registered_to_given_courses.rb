class CreateAssistantRegisteredToGivenCourses < ActiveRecord::Migration
  def self.up
    create_table :assistant_registered_to_given_courses do |t|
      t.references :GivenCourse
      t.references :Assistant
      t.boolean :can_change_deadline

      t.timestamps
    end
  end

  def self.down
    drop_table :assistant_registered_to_given_courses
  end
end
