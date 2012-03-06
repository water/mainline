class LabHasGroup < ActiveRecord::Base
  belongs_to :lab
  belongs_to :lab_group
  has_one :repository

  has_one :assistant_registered_to_given_course
  has_one :assistant_registered_to_given_course, through: :assistant_registered_to_given_courses_lab_has_group
end
