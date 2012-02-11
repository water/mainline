# encoding: utf-8

module CommitsHelper
  include RepositoriesHelper
  include CommentsHelper
  include DiffHelper
  
  def format_commit_message(message)
    message.gsub(/\b[a-z0-9]{40}\b/) do |match|
      link_to(match, repo_owner_path(@repository, :project_repository_commit_path, 
                                     @project, @repository, match), :class => "sha")
    end
  end
  
end
