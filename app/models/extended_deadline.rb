class ExtendedDeadline < ActiveRecord::Base
  belongs_to :lab_group, foreign_key: "group_id"
  belongs_to :lab

  validates_presence_of :lab, :lab_group, :at
  validate :time_span, :time_difference

  # What's the minimum time between 
  # each deadline for a given group?
  MINIMUM_TIME_DIFFERENCE = 1.day

private
  def time_span
    if at and at < Time.zone.now
      errors[:at] << "must be a future value"
    end
  end

  def time_difference
    in_valid = ExtendedDeadline.where(group_id: group_id).any? do |d| 
      (d.at.to_i - self.at.to_i) < MINIMUM_TIME_DIFFERENCE.to_i
    end

    if in_valid
      errors[:at] << "a bit to similar to some another deadline"
    end
  end
end
