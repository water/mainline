class Submission < ActiveRecord::Base
  belongs_to :lab_has_group
  has_one :lab, through: :lab_has_group
  has_one :repository, through: :lab_has_group
  has_one :lab_group, through: :lab_has_group

  validates_format_of :commit_hash, with: /^[a-f0-9]{40}$/
  validates_presence_of :commit_hash, :lab_has_group
  validate :lab_access
  validate :commit_hash_exists

  alias_method :repo, :repository
  
  #
  # Looks for a LabHasGroup
  # Fetches the latest commit for the repo connectet to the LabHasGroup
  # Creates a submission with the commit hash
  #
  # @arg options, a hash containing options you would normally pass to #create!
  #
  def self.create_from_latest_commit!(args)
    if lhg = args[:lab_has_group]
      args[:commit_hash] ||= lhg.repository.head_candidate.commit
      Submission.create!(args)
    else
      raise(ArgumentException, "No LabHasGroup was provided.")
    end
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
