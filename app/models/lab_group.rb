class LabGroup < ActiveRecord::Base
  has_and_belongs_to_many :registered_courses
  has_many :labs, through: :lab_has_group
  has_many :submissions, through: :lab_has_group
  accepts_nested_attributes_for :lab_has_groups
end
