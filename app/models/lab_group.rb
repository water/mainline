class LabGroup < ActiveRecord::Base
  has_and_belongs_to_many :registered_courses
  has_many :labs, through: :lab_has_group
  has_many :lab_has_groups
  has_many :submissions, through: :lab_has_groups
  belongs_to :given_course
  has_many :students, through: :registered_courses, class_name: "Student"
  acts_as_list scope: :given_course, column: :identification
end