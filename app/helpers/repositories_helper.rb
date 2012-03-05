# encoding: utf-8

module RepositoriesHelper
  def log_path(objectish = "master", options = {})
    objectish = ensplat_path(objectish)
    if options.blank? # just to avoid the ? being tacked onto the url
      repo_owner_path(@repository, :project_repository_commits_in_ref_path, @project, @repository, objectish)
    else
      repo_owner_path(@repository, :project_repository_commits_in_ref_path, @project, @repository, objectish, options)
    end
  end

  def commit_path(objectish = "master")
    repo_owner_path(@repository, :repository_commit_path, @repository, objectish)
  end
  
  def hash_path(ref, path, type)
    "#/#{type}/#{ref}/#{path}"
  end
  
  def tree_path(treeish = "master", path = [], *args)
    if path.respond_to?(:to_str)
      path = path.split("/")
    end
    repo_owner_path(@repository, :repository_tree_path, @repository, branch_with_tree(treeish, path), *args)
  end
  
  def submission_path(treeish = "master", path = [])
    if path.respond_to?(:to_str)
      path = path.split("/")
    end
    repo_owner_path(@repository, :lab_submission_tree_path, @lab, @submission, @repository, branch_with_tree(treeish, path))
  end

  def repository_path(action, sha1=nil)
    repo_owner_path(@repository, :project_repository_path, @project, @repository)+"/"+action+"/"+sha1.to_s
  end

  def blob_path(shaish, path, *args)
    repo_owner_path(@repository, :repository_blob_path, @repository, branch_with_tree(shaish, path), *args)
  end

  def raw_blob_path(shaish, path)
    repo_owner_path(@repository, :project_repository_raw_blob_path, @project, @repository, branch_with_tree(shaish, path))
  end

  def blob_history_path(shaish, path)
    repo_owner_path(@repository, :project_repository_blob_history_path, @project, @repository, branch_with_tree(shaish, path))
  end

  def namespaced_branch?(branchname)
    branchname.include?("/")
  end

  def edit_or_show_group_text
    if @repository.admin?(current_user)
      t("views.repos.edit_group")
    else
      t("views.repos.show_group")
    end
  end

  def render_branch_list_items(branches)
    sorted_git_heads(branches).map do |branch|
      content_tag(:li,
        link_to(h(branch.name), log_path(branch.name), :title => branch_link_title_text(branch)),
        :class => "branch #{highlight_if_head(branch)}")
    end.join("\n  ")
  end

  def highlight_if_head(branch)
    if branch.head?
      "head"
    end
  end

  def branch_link_title_text(branch)
    "branch " + h(branch.name) + (branch.head? ? " (HEAD)" : "")
  end

  # Sorts the +heads+ alphanumerically with the HEAD first
  def sorted_git_heads(heads)
    heads.select{|h| !h.head? }.sort{|a,b|
      a.name <=> b.name
    }.unshift(heads.find{|h| h.head? }).compact
  end

  # Renders a set of list items, cut off at around +max_line_length+
  def render_chunked_branch_list_items(repository, max_line_length = 80)
    heads = sorted_git_heads(repository.git.heads)

    cumulative_line_length = 0
    heads_to_display = heads.select do |h|
      cumulative_line_length += (h.name.length + 2)
      cumulative_line_length < max_line_length
    end

    list_items = heads_to_display.map do |head|
      li = %Q{<li class="#{highlight_if_head(head)}">}
      li << link_to(h(head.name), repo_owner_path(repository, :project_repository_commits_in_ref_path,
                 repository.project, repository, ensplat_path(head.name)),
              :title => branch_link_title_text(head))
      li << "</li>"
      li
    end

    if heads_to_display.size < repository.git.heads.size
      rest_size = repository.git.heads.size - heads_to_display.size
      list_items << %{<li class="rest-of-branches">
                        <small>and #{rest_size} more&hellip;</small>
                      </li>}
    end

    list_items.join("\n")
  end

  def show_clone_list_search?(group_clones, user_clones)
    user_clones.size >= 5 || group_clones.size >= 5
  end

  def css_class_for_extended_clone_url_field(repository)
    if (logged_in? && !current_user.can_write_to?(repository)) || !logged_in?
      return "extended"
    end
  end
end
