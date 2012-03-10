module DeadlineTimeSpanValidation
  def self.included(base)
    @@BASE = base
    base.instance_eval do
      validate :time_difference
      @@MINIMUM_TIME_DIFFERENCE = base::MINIMUM_TIME_DIFFERENCE
    end
  end

  def time_difference
    in_valid = @@BASE.where(group_id: group_id).any? do |d| 
      (d.at.to_i - self.at.to_i) < @@MINIMUM_TIME_DIFFERENCE.to_i
    end

    if in_valid
      errors[:at] << "a bit to similar to some another deadline"
    end
  end
end