class RegisteredCourse < ActiveRecord::Base
  belongs_to :student, class_name: "User"
  belongs_to :given_course
  validates_uniqueness_of :student_id, scope: [:given_course_id]
  validates_presence_of :student, :given_course
end
