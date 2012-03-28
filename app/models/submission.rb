class Submission < ActiveRecord::Base
  include ExistenceOfCommitHashValidation
  belongs_to :lab_has_group
  has_one :lab, through: :lab_has_group
  has_one :repository, through: :lab_has_group
  has_one :lab_group, through: :lab_has_group

  validates_format_of :commit_hash, with: /^[a-f0-9]{40}$/
  validates_presence_of :commit_hash, :lab_has_group
  validate :lab_access
  validate :existence_of_commit_hash
  validate :lab_has_group_state
  before_validation :fetch_commit

  #
  # Change LabHasGroup state to pending
  #
  after_save do |submission|
    submission.lab_has_group.pending!
  end

  #
  # Looks for a LabHasGroup
  # Fetches the latest commit for the repo connectet to the LabHasGroup
  # Creates a submission with the commit hash
  #
  # @arg options, a hash containing options you would normally pass to #create!
  #
  def self.create_at_latest_commit!(args)
    if lhg = args[:lab_has_group]
      args[:commit_hash] = lhg.repository.head_candidate.commit
      Submission.create!(args)
    else
      raise ArgumentError.new("No LabHasGroup was provided.")
    end
  end

  private
    #
    # The given lab {lab} must be active
    #
    def lab_access
      if lab and not lab.active?
        errors[:lab_access]  << "failed, lab not accessible"
      end
    end

    #
    # Use last commit from {repository} as {commit_hash}
    #
    def fetch_commit
      self.commit_hash ||= repository.try(:head_candidate).try(:commit)
    end

    #
    # Is it possible to create a submission
    # for a given LabHasGroup?
    # The following LabHasGroup#state's will result
    # in a non valid submission object
    # - accepted
    # - reviewing
    # - pending
    #
    def lab_has_group_state
      return unless lab_has_group

      if lab_has_group.accepted?
        errors.add(:lab_has_group, %q{
          The corresponding lab has already been accepted
        })
      elsif lab_has_group.reviewing?
        errors.add(:lab_has_group, %q{
          The corresponding lab is being reviewed
        })
      elsif lab_has_group.pending?
        errors.add(:lab_has_group, %q{
          A pending submission already exists
        })
      end
    end
end
