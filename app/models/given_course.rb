class GivenCourse < ActiveRecord::Base
  belongs_to :course
  belongs_to :study_period

  has_and_belongs_to_many :examiners
  
  has_many :student_registered_for_courses, dependent: :destroy
  has_many :students, through: :student_registered_for_courses

  has_many :assistant_registered_to_given_courses
  has_many :assistants, through: :assistant_registered_to_given_courses
  
  has_many :lab_groups
  has_many :labs

  validates_presence_of :course, :examiners, :study_period
end
