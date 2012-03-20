class StudentRegisteredForCourse < ActiveRecord::Base
  belongs_to :student
  belongs_to :given_course
  has_and_belongs_to_many :lab_groups
  has_and_belongs_to_many :lab_has_groups  
  validates_uniqueness_of :student_id, scope: [:given_course_id]
  validates_presence_of :student, :given_course
end