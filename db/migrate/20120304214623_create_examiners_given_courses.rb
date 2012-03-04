class CreateExaminersGivenCourses < ActiveRecord::Migration
  def up
    create_table :examiners_given_courses, id: false do |t|
      t.references :examiner
      t.references :given_course
    end
  end

  def down
    drop_table :examiners_given_courses
  end
end
