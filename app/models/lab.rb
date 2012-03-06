class Lab < ActiveRecord::Base

  belongs_to :lab_description, foreign_key: "description_id"
  belongs_to :given_course, foreign_key: "given_course_id"

  validates_presence_of :lab_description, :given_course, :number
  validates_numericality_of :number
  has_many :lab_has_groups
  has_many :lab_groups, through: :lab_has_groups
  #validates_uniqueness_of :lab_description, :scope => :given_course
end