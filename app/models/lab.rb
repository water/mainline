class Lab < ActiveRecord::Base
  belongs_to :GivenCourse
  belongs_to :LabDescription
end
