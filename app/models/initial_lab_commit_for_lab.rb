class InitialLabCommitForLab < ActiveRecord::Base
  belongs_to :initial_lab_commit
  belongs_to :lab
  validates_presence_of :lab, :initial_lab_commit
  validates_uniqueness_of :lab_id
end
