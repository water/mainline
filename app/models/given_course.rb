class GivenCourse < ActiveRecord::Base
  belongs_to :course
  belongs_to :when

  has_and_belongs_to_many :examiners
  
  has_many :registered_courses
  has_many :students, through: :registered_courses, class_name: "User"

  has_many :assistant_registered_to_given_courses
  has_many :assistants, through: :assistant_registered_to_given_courses, class_name: "User"
  
  validates_presence_of :course, :examiners, :when
end
