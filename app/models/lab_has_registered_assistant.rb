class LabHasRegisteredAssistant < ActiveRecord::Base
  belongs_to :AssistantRegisteredToGivenCourse
  belongs_to :Lab
  belongs_to :When
end
