# encoding: utf-8

class MergeRequestVersion < ActiveRecord::Base
  include ActiveMessaging::MessageSender
  
  belongs_to :merge_request
  has_many :comments, :as => :target, :include => :user
  before_destroy :schedule_branch_deletion

  def affected_commits
    Rails.cache.fetch(cache_key + '/affected_commits') do
      @affected_commits ||= merge_request.tracking_repository.git.commits_between(
        merge_base_sha, merge_request.merge_branch_name(version)).reverse
    end
  end

  def diffs(sha_or_range=nil)
    case sha_or_range
    when Range
      diff_backend.commit_diff(sha_or_range.begin, sha_or_range.end, true)
    when String
      diff_backend.single_commit_diff(sha_or_range)
    else
      diff_backend.commit_diff(merge_base_sha, merge_request.ending_commit)
    end    
  end

  def comments_for_path_and_sha(path, sha)
    comments.select{|c|(c.path == path && c.sha1 == sha_range_string(sha))}
  end

  def comments_for_sha(sha, options={})
    result = comments.select{|c|c.sha1 == sha_range_string(sha)}
    if options[:include_merge_request_comments]
      result.concat(merge_request.comments)
    end
    result
  end

  def short_merge_base
    merge_base_sha[0..6]
  end

  def sha_summary(format = :short)
    if affected_commits.blank?
      format == :short ? short_merge_base : merge_base_sha
    else
      meth = format == :short ? :id_abbrev : :id
      [affected_commits.last, affected_commits.first].collect(&meth).join("-")
    end
  end

  def diff_backend
    @diff_backend ||= DiffBackend.new(merge_request.target_repository.git)
  end

  class DiffBackend
    def initialize(repository)
      @repository = repository
    end

    # Returns the sha of +sha+'s parent. If none, return +sha+
    def parent_commit_sha(sha)
      first_parent = commit = Grit::Commit.find_all(@repository, sha,
        {:max_count => 1}).first.parents.first
      if first_parent.nil?
        sha
      else
        first_parent.id
      end
    end
    
    def cache_key(first, last=nil)
      ["merge_request_diff_v1", first, last].compact.join("_")
    end
    
    def commit_diff(first, last, diff_with_previous=false)
      Rails.cache.fetch(cache_key(first,last)) do
        first_commit_sha = if diff_with_previous
                             parent_commit_sha(first)
                           else
                             first
                           end
        diff_string = @repository.git.ruby_git.diff(first_commit_sha ,last)
        Grit::Diff.list_from_string(@repository, diff_string)
      end
    end

    def single_commit_diff(sha)
      Rails.cache.fetch(cache_key(sha)) do
        @repository.commit(sha).diffs
      end
    end
  end

  # The unserialized message that is sent to the message queue
  # for deleting the tracking branch
  def branch_deletion_message
    {
      :source_repository_path => merge_request.source_repository.full_repository_path,
      :tracking_repository_path => merge_request.tracking_repository.full_repository_path,
      :target_branch_name => merge_request.merge_branch_name(version),
      :source_repository_id => merge_request.source_repository.id
    }
  end

  def schedule_branch_deletion
    message = branch_deletion_message.to_json
    publish :merge_request_version_deletion, message
  end
  
  private
  # Returns a string representation of a sha range
  def sha_range_string(string_or_range)
    if Range === string_or_range
      string_or_range = [string_or_range.begin, string_or_range.end].join("-")
    end
    string_or_range
  end
end
