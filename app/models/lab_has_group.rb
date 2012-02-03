class LabHasGroup < ActiveRecord::Base
  belongs_to :Lab
  belongs_to :LabGroup
end
