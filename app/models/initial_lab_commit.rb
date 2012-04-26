class InitialLabCommit < ActiveRecord::Base
  include ExistenceOfCommitHashValidation
  belongs_to :repository
  has_many :initial_lab_commit_for_labs
  has_many :labs, through: :initial_lab_commit_for_labs
  validates_presence_of :repository, :commit_hash
  validates_format_of :commit_hash, with: /^[a-f0-9]{40}$/
  validate :existence_of_commit_hash
end