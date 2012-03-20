class LabGroup < ActiveRecord::Base
  has_and_belongs_to_many :student_registered_for_courses
  has_many :lab_has_groups
  has_many :labs, through: :lab_has_groups
  has_many :submissions, through: :lab_has_groups
  belongs_to :given_course
  has_many :student_registered_for_courses, through: :lab_has_groups
  has_many :students, through: :student_registered_for_courses

  acts_as_list scope: :given_course, column: :number
  accepts_nested_attributes_for :lab_has_groups
end