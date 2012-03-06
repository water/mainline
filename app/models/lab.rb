class Lab < ActiveRecord::Base

  belongs_to :lab_description, foreign_key: "description_id"
  belongs_to :given_course

  validates_presence_of :lab_description, :given_course, :number
  has_many :lab_has_groups
  has_many :lab_groups, through: :lab_has_groups
  #validates_uniqueness_of :lab_description, :scope => :given_course

  acts_as_list scope: :given_course, column: :number
end