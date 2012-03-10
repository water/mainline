class LabDefaultDeadline < ActiveRecord::Base
  belongs_to :lab

  validates_presence_of :lab, :at
  #validates_uniqueness_of :lab

  # What's the minimum time between 
  # each deadline for a given group?
  MINIMUM_TIME_DIFFERENCE = 1.day
  include DeadlineTimeSpanValidation
end
