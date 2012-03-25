class Submission < ActiveRecord::Base
  belongs_to :lab_has_group
  has_one :lab, through: :lab_has_group
  has_one :repository, through: :lab_has_group
  has_one :lab_group, through: :lab_has_group

  validates_format_of :commit_hash, with: /^[a-f0-9]{40}$/
  validates_presence_of :commit_hash, :lab_has_group
  validate :lab_access
  validate :existence_of_commit_hash

  before_validation :fetch_commit

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
    # Does the given commit {commit_hash} exist?
    #
    def existence_of_commit_hash
      path = repository.try(:full_repository_path)
      Dir.chdir(path) do
        unless system "git rev-list HEAD..#{commit_hash}"
          errors[:commit_hash] << "does not exist"
        end
      end if File.exists?(path)
    end
end
