class LabGroup < ActiveRecord::Base
  has_and_belongs_to_many :registered_courses
  has_many :labs, through: :lab_has_group
  has_many :submissions, through: :lab_has_group
  belongs_to :given_course
  acts_as_list scope: :given_course, column: :identification
end
