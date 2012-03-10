class ExtendedDeadline < ActiveRecord::Base
  belongs_to :lab_group, foreign_key: "group_id"
  belongs_to :lab

  validates_presence_of :lab, :lab_group, :at
  validate :time_span

private
  def time_span
    if at and at < Time.zone.now
      errors[:at] << "must be a future value"
    end
  end
end
