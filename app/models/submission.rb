class Submission < ActiveRecord::Base
  belongs_to :lab_has_group
  has_one :lab, through: :lab_has_group
  has_one :repository, through: :lab_has_group
  has_one :lab_group, through: :lab_has_group

  validates_format_of :commit_hash, with: /^[a-f0-9]{40}$/
  validates_presence_of :lab_group, :lab, :commit_hash
  validate :lab_access

  alias_method :repo, :repository

  private
    def lab_access
      if lab and not lab.active?
        errors[:lab_access]  << "failed, lab not accessible"
      end
    end
end