class Lab < ActiveRecord::Base
  belongs_to :lab_description, foreign_key: "description_id"
  belongs_to :given_course

  has_many :lab_has_groups
  has_many :lab_groups, through: :lab_has_groups
  has_many :submissions

  has_one :initial_lab_commit_for_lab
  has_one :initial_lab_commit, through: :initial_lab_commit_for_lab

  validates_presence_of :lab_description, :given_course, :number
  validates_uniqueness_of :description_id, scope: :given_course_id

  acts_as_list scope: :given_course, column: :number

  default_scope where("labs.active = ?", true)
end