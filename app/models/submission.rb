class Submission < ActiveRecord::Base
  belongs_to :lab_has_group
  belongs_to :lab_group, foreign_key: "group_id"
  has_one :lab, through: :lab_has_group
  has_one :repository, through: :lab_has_group

  validates_format_of :commit_hash, with: /^[a-f0-9]{40}$/
  validates_presence_of :lab_group, :lab, :commit_hash

  alias_method :repo, :repository
end