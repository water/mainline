class Submission < ActiveRecord::Base
  belongs_to :lab_has_group
  has_one :lab, through: :lab_has_group
  has_one :repository, through: :lab_has_group
  has_one :lab_group, through: :lab_has_group

  validates_format_of :commit_hash, with: /^[a-f0-9]{40}$/
  validates_presence_of :commit_hash, :lab_has_group
  validate :lab_access
  validate :commit_hash_exists

  before_validation :fetch_commit, :if=>lambda {|a| a.commit_hash.nil?}

  alias_method :repo, :repository

  def fetch_commit
    @temp = lab_has_group.repository.head_candidate.commit
    define_singleton_method(:commit_hash) { @temp } # FIXME: fulhack :)
  end

  private
    def lab_access
      if lab and not lab.active?
        errors[:lab_access]  << "failed, lab not accessible"
      end
    end

    def commit_hash_exists
      # TODO: define
    end
end
