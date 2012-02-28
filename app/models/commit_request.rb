class CommitRequest 
	include ActiveModel::Validations
	include ActiveModel::Conversion
	extend ActiveModel::Naming

  attr_accessor :user, :command, :repository, :branch, :commit_message, :files, :paths

  validates_presence_of :user,:command, :repository, :branch, :commit_message, :files
  validates_numericality_of :user, :repository
  validates_inclusion_of :command, :in => %w( move add remove ), :message => "%s is not an acceptable command" 

  validate :existence_of_user, :existence_of_repository, :commit_access

  def initialize(options = {})
    @options = options
    options.each do |name, value|
      send("#{name}=",value)
    end
    @commit_message ||= generate_commit_message
  end

  def generate_commit_message
    return "WebCommit: #{@command}"
  end

  def save
    return false unless valid?
    enqueue
  end

  def enqueue
    raise "not implemented yet, blame linus"
  end

  def persisted?
    false
  end
private 
  def existence_of_user
    unless User.exists?(@user)
      errors[:user] << "does not exist"
    end
  end

  def existence_of_repository
    unless Repository.exists?(@repository)
      errors[:repository] << "does not exist"
    end
  end

  def commit_access
    unless user_can_commit?
      errors[:user_can_commit] << %q{
        Permission denied, user is not allowed to commit to this repo
      }
    end
  end

  def user_can_commit?
    sids = GroupHasUser.find_all_by_student_id(@user)
    sids.any?{ | x | LabHasGroup.find(x.lab_group_id).repo_id == @repository }
  end

end

