class AssistantRegisteredToGivenCourse < ActiveRecord::Base
  belongs_to :GivenCourse
  belongs_to :Assistant
end
