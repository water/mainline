class GroupHasUser < ActiveRecord::Base
  belongs_to :student
  belongs_to :lab_group
end
