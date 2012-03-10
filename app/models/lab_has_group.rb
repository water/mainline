class LabHasGroup < ActiveRecord::Base
  belongs_to :lab
  belongs_to :lab_group
  belongs_to :repository
  has_many :submissions
  has_one :assistant_registered_to_given_courses_lab_has_group
  has_one :assistant_registered_to_given_course, through: :assistant_registered_to_given_courses_lab_has_group
  has_one :assistant, through: :assistant_registered_to_given_course

  validates_presence_of :lab, :lab_group, :repository
  validates_uniqueness_of :lab_id, scope: :lab_group_id
end