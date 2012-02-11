# encoding: utf-8

class Page
  class UserNotSetError < StandardError; end
  
  # TODO: support for more formats
  DEFAULT_FORMAT = "markdown"
  # TODO: support nested pages
  TITLE_FORMAT = /([A-Z][a-z]+)/.freeze
  
  def self.find(name, repo, format = DEFAULT_FORMAT)
    fullname = "#{name}.#{format}"
    blob = find_or_create_blob(fullname, repo)
    new(fullname, blob, repo)
  end
  
  def self.find_or_create_blob(fullname, repo)
    if blob = repo.tree/fullname
      return blob
    else
      Grit::Blob.create(repo, :name => fullname, :data => '')
    end
  end
  
  def initialize(name, blob, repo)
    @name = name
    @blob = blob
    @repo = repo
  end
  attr_accessor :user, :name
  
  def content
    @content ||= @blob.data
  end
  
  def content=(new_content)
    @content = new_content
  end
  
  def new?
    @blob.id.nil?
  end
  
  def new_record?
    # always false as a easy hack around rails' form handling
    false 
  end
  
  def to_param
    title
  end
  alias_method :id, :to_param
  
  def title
    name.sub(/\.#{DEFAULT_FORMAT}$/, "")
  end
  
  def reload
    @blob = @repo.tree/@name
  end
  
  def commit
    return if new?
    logs = @repo.log("master", @name, {:max_count => 1})
    return if logs.empty?
    logs.first
  end
  
  def committed_by_user
    return user if new?
    User.find_by_email_with_aliases(commit.committer.email)
  end
  
  def valid?
    (title =~ TITLE_FORMAT)  == 0
  end
  
  def save
    return false unless valid?
    raise UserNotSetError unless user
    actor = user.to_grit_actor
    index = @repo.index
    index.add(@name, @content)
    msg = new? ? "Created #{@name}" : "Updated #{title}"
    if head = @repo.commit("HEAD")
      parents = [head.id]
      last_tree = index.read_tree(head.tree.id)
    else
      parents = []
      last_tree = nil
    end
    index.commit(msg, parents, actor, last_tree)
  end
  
  def history(max_count = 30)
    @repo.log("master", @name, {:max_count => max_count})
  end
end
