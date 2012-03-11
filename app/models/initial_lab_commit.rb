class InitialLabCommit < ActiveRecord::Base
  belongs_to :repository
  has_one :initial_lab_commit_for_lab
  has_one :lab, through: :initial_lab_commit_for_lab
end
