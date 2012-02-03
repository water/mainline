class CreateGivenCourses < ActiveRecord::Migration
  def self.up
    create_table :given_courses do |t|
      t.references :Course
      t.references :Examiner
      t.references :When

      t.timestamps
    end
  end

  def self.down
    drop_table :given_courses
  end
end
