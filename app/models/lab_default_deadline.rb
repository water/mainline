class LabDefaultDeadline < ActiveRecord::Base
  belongs_to :lab

  validates_presence_of :lab, :at
  #validates_uniqueness_of :lab

  validate :time_difference

  # What's the minimum time between 
  # each deadline for a given group?
  MINIMUM_TIME_DIFFERENCE = 1.day

private
  def time_difference
    in_valid = LabDefaultDeadline.where(lab_id: lab_id).any? do |d| 
      (d.at.to_i - self.at.to_i) < MINIMUM_TIME_DIFFERENCE.to_i
    end

    if in_valid
      errors[:at] << "a bit to similar to some another deadline"
    end
  end
end
