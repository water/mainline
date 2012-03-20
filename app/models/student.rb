class Student < ActiveRecord::Base
  belongs_to :user
  has_many :student_registered_for_courses
  has_many :lab_groups, through: :student_registered_for_courses
  has_many :labs, through: :lab_groups
  has_and_belongs_to_many :given_courses, join_table: "student_registered_for_courses"
  validates_presence_of :user
  
  #
  # Checks whether a student is registered for a given course.
  #
  def registered_for_course?(given_course)
    StudentRegisteredForCourse.reg_for_student_and_course.exists?
  end
  
end