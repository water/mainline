class LabDefaultDeadline < ActiveRecord::Base
  belongs_to :lab

  validates_presence_of :lab, :at
  validates_uniqueness_of :lab
end
