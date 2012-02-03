class CreateRegisteredCourses < ActiveRecord::Migration
  def self.up
    create_table :registered_courses do |t|
      t.references :Student
      t.references :GivenCourse

      t.timestamps
    end
  end

  def self.down
    drop_table :registered_courses
  end
end
