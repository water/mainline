class Examiner < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :given_courses
  has_many :labs, through: :given_courses
  has_many :submissions, through: :labs
  has_many :lab_groups, through: :given_courses
  has_many :students, through: :given_courses
  validates_presence_of :user
end
