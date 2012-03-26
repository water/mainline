class StudentRegisteredForCourse < ActiveRecord::Base
  belongs_to :student
  belongs_to :given_course
  has_and_belongs_to_many :lab_groups
  
  validates_uniqueness_of :student_id, scope: [:given_course_id]
  validates_presence_of :student, :given_course
  
  #
  # Gets the StudentRegisteredForCourse object 
  # for a combination of a student and a given course
  #
  def self.reg_for_student_and_course(student, given_course)
    self.where(student_id: student.id, given_course_id: given_course.id).limit(1)
  end
end