class LabGroup < ActiveRecord::Base
  has_and_belongs_to_many :student_registered_for_courses
  has_many :lab_has_groups
  has_many :labs, through: :lab_has_groups
  has_many :submissions, through: :lab_has_groups
  belongs_to :given_course
  has_many :students, through: :student_registered_for_courses, class_name: "Student"

  acts_as_list scope: :given_course, column: :number
  accepts_nested_attributes_for :lab_has_groups
  
  #
  # Adds a student to a lab group.
  # Checks that the student is registered to the correct course.
  #
  def add_student(student)
    @registration = StudentRegisteredForCourse.reg_for_student_and_course(student, self.given_course)
    if @registration
      self.student_registered_for_courses << @registration
    end
  end
end