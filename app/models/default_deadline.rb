class DefaultDeadline < ActiveRecord::Base
  belongs_to :lab, inverse_of: :default_deadlines

  validates_presence_of :lab, :at
  validate :time_difference, :time_span
  
  default_scope order("at asc")

  # What's the minimum time between 
  # each deadline for a given group?
  MINIMUM_TIME_DIFFERENCE = 1.day

private
  def time_difference
    in_valid = DefaultDeadline.
      where("default_deadlines.lab_id = ?", lab_id).
      where("default_deadlines.id != ?", id.to_i).
    any? do |d|
      (d.at.to_i - self.at.to_i).abs < MINIMUM_TIME_DIFFERENCE.to_i
    end
    
    if in_valid
      errors[:at] << "a bit too similar to some another deadline"
    end
  end

  def time_span
    if at and at < Time.zone.now
      errors[:at] << "must be a future value"
    end
  end
end


