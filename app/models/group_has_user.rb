class GroupHasUser < ActiveRecord::Base
  belongs_to :Student
  belongs_to :LabGroup
end
