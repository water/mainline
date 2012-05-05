class AssistantRegisteredToGivenCourse < ActiveRecord::Base
  belongs_to :given_course
  belongs_to :assistant
  has_many :assistant_registered_to_given_course_has_lab_has_groups
  has_many :lab_has_groups, through: :assistant_registered_to_given_course_has_lab_has_groups
  validates_presence_of :given_course, :assistant
end
