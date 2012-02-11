class AssistantRegisteredToGivenCourse < ActiveRecord::Base
  belongs_to :given_course
  belongs_to :assistant, class_name: "User"
  
  validates_presence_of :given_course, :assistant
end
