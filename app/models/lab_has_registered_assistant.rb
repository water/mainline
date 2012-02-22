class LabHasRegisteredAssistant < ActiveRecord::Base
  belongs_to :assistant_registered_to_given_course
  belongs_to :lab
  belongs_to :when
end
