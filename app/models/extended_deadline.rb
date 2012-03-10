class ExtendedDeadline < ActiveRecord::Base
  belongs_to :lab_group, foreign_key: "group_id"
  belongs_to :lab

  validates_presence_of :lab, :lab_group, :at
  validate :time_span

  # What's the minimum time between 
  # each deadline for a given group?
  MINIMUM_TIME_DIFFERENCE = 1.day
  include DeadlineTimeSpanValidation

private
  def time_span
    if at and at < Time.zone.now
      errors[:at] << "must be a future value"
    end
  end
end
