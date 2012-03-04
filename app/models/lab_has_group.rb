class LabHasGroup < ActiveRecord::Base
  belongs_to :lab
  belongs_to :lab_group
  has_one :repository
end
