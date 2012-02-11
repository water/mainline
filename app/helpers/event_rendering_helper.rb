# encoding: utf-8
module EventRenderingHelper
  def render_event_create_project(event)
    action = action_for_event(:event_status_created) do
      link_to h(event.target.title), project_path(event.target)
    end
    body = truncate(event.target.stripped_description, :length => 100)
    category = "project"
    [action, body, category]
  end

  def render_event_delete_project(event)
    action = action_for_event(:event_status_deleted){ h(event.data) }
    category = "project"
    [action, "", category]
  end

  def render_event_update_project(event)
    action = action_for_event(:event_status_updated) do
      link_to h(event.target.title), project_path(event.target)
    end
    category = "project"
    [action, "", category]
  end

  def render_event_update_repository(event)
    action = action_for_event(:event_updated_repository) do
      link_to(h(event.target.url_path),
        repo_owner_path(event.target, :project_repository_path, event.target.project, event.target))
    end
    category = 'repository'
    [action, event.body, category]
  end

  def render_event_clone_repository(event)
    original_repo = Repository.find_by_id(event.data.to_i)
    return ["", "", ""] if original_repo.nil?

    project = event.target.project

    action = action_for_event(:event_status_cloned) do
      link_to(h(original_repo.url_path), repo_owner_path(original_repo, [project, original_repo]))
    end
    body = "New repository is in " + link_to(h(event.target.name), repo_owner_path(event.target, [project, event.target]))
    category = "repository"
    [action, body, category]
  end

  def render_event_delete_repository(event)
    action = action_for_event(:event_status_deleted) do
      link_to(h(event.target.title), event.target) + "/" + h(event.data)
    end
    category = "project"
    [action, "", category]
  end

  def render_event_commit(event)
    project = event.project
    repo = event.target

    case repo.kind
    when Repository::KIND_WIKI
      action = action_for_event(:event_status_push_wiki) do
        "to " + link_to(h(project.slug), project_path(project)) +
        "/" + link_to(h(t("views.layout.pages")), project_pages_url(project))
      end
      body = h(truncate(event.body, :length => 150))
      category = "wiki"
    when 'commit'
      action = action_for_event(:event_status_committed) do
        link_to(event.data[0,8], project_repository_commit_path(project, repo, event.data)) +
        " to " + link_to(h(project.slug), project)
      end
      body = link_to(h(truncate(event.body, :length => 150)),
              project_repository_commit_path(project, repo, event.data))
      category = "commit"
    else
      action = action_for_event(:event_status_committed) do
        link_to(h(event.data[0,8]), repo_owner_path(repo, :project_repository_commit_path, project, repo, event.data)) +
        " to " + link_to(h(project.slug), project)
      end
      body = link_to(h(truncate(event.body, :length => 150)), project_repository_commit_path(project, repo, event.data))
      category = "commit"
    end

    [action, body, category]
  end

  def render_event_create_branch(event)
    project = event.target.project
    if event.data == "master"
      action = action_for_event(:event_status_started) do
        "of " + link_to(h(project.slug), project_path(project)) + "/" +
        link_to(h(event.target.name), project_repository_url(project, event.target))
      end
      body = h(event.body)
    else
      action = action_for_event(:event_branch_created) do
        link_to(h(event.data),
          repo_owner_path(event.target, :project_repository_commits_in_ref_path,
            project, event.target, ensplat_path(event.data))) +
        " on " + link_to(h(project.slug), project_path(project)) + "/" +
        link_to(h(event.target.name),
          repo_owner_path(event.target, :project_repository_url, project, event.target))
      end
    end
    category = "commit"
    [action, "", category]
  end

  def render_event_delete_branch(event)
    project = event.target.project
    action = action_for_event(:event_branch_deleted) do
      h(event.data)  + " on " + link_to(h(project.slug), project_path(project)) +
      "/" + link_to(h(event.target.name),
              repo_owner_path(event.target, :project_repository_url, project, event.target))
    end
    category = "commit"
    [action, "", category]
  end

  def render_event_create_tag(event)
    project = event.target.project
    action = action_for_event(:event_tagged) do
      link_to(h(project.slug), project_path(project))  + "/" +
      link_to(h(event.target.name), project_repository_url(project, event.target))
    end
    body = link_to(h(event.data) + ": " + h(event.body), project_repository_commit_path(project, event.target, h(event.data)))
    category = "commit"
    [action, body, category]
  end

  def render_event_delete_tag(event)
    action = action_for_event(:event_tag_deleted) do
      h(event.data) + " on " + link_to(h(event.project.slug), project_path(event.project)) +
      "/" + link_to(h(event.target.name), @template.project_repository_url(event.project, event.target))
    end
    category = "commit"
    [action, "", category]
  end

  def render_event_add_committer(event)
    repo = event.target.is_a?(Repository) ? event.target : event.target.repository
    action = action_for_event(:event_committer_added, :collaborator => h(event.data)) do
      " to " + link_to(repo_title(repo, event.project), repo_owner_path(repo, [repo.project, repo]))
    end
    category = "repository"
    [action, "", category]
  end

  def render_event_remove_committer(event)
    repo = event.target
    action = action_for_event(:event_committer_removed, :collaborator => h(event.data)) do
      " from " + link_to(repo_title(repo, event.project), repo_owner_path(repo, [repo.project, repo]))
    end
    category = "repository"
    [action, "", category]
  end

  def render_event_comment(event)
    comment = Comment.find(event.data)

    if event.body == "MergeRequest"
      repo = event.target.target_repository
      project = repo.project
    else
      project = event.target.project
      repo = event.target
    end

    if comment.applies_to_merge_request? || MergeRequestVersion === comment.target
      if event.body == "MergeRequest"
        action = action_for_event(:event_commented) do
          " on merge request " +  link_to(h(repo.url_path) +
            " " + h("##{event.target.to_param}"),
            repo_owner_path(repo, :project_repository_merge_request_path,
              project, repo, event.target)+"##{dom_id(comment)}")
        end
      else
        action = action_for_event(:event_commented) do
          " on " +  link_to(h(repo.url_path), repo_owner_path(repo, [project, repo]))
        end
      end
    else
      if comment.sha1.blank? # old-world repo comments
        action = action_for_event(:event_commented) do
          " on " +  link_to(h(repo.url_path),
            repo_owner_path(repo, :project_repository_comments_path, project, repo) +
            "##{dom_id(comment)}")
        end
      else
        action = action_for_event(:event_commented) do
          " on " +  link_to(h(repo.url_path + '/' + comment.sha1[0,7]),
            repo_owner_path(repo, :project_repository_commit_path, project, repo,
              comment.sha1)+"##{dom_id(comment)}")
        end
      end
    end
    body = truncate(h(comment.body), :length => 150)
    category = "comment"
    [action, body, category]
  end

  def render_event_request_merge(event)
    source_repository = event.target.source_repository
    project = source_repository.project
    target_repository = event.target.target_repository

    action = action_for_event(:event_requested_merge_of) do
      link_to(repo_title(source_repository, project),
        repo_owner_path(source_repository, [project, source_repository])) +
      " with " + link_to(h(target_repository.name),
        repo_owner_path(target_repository, [project, target_repository]))
    end
    body = link_to truncate(h(event.target.proposal), :length => 100), [project, target_repository, event.target]
    category = "merge_request"
    [action, body, category]
  end

  def render_event_resolve_merge_request(event)
    source_repository = event.target.source_repository
    project = source_repository.project
    target_repository = event.target.target_repository

    action = action_for_event(:event_resolved_merge_request) do
      "as " + "<em>#{event.target.status_string}</em> from " +
      link_to(repo_title(source_repository, project),
        repo_owner_path(source_repository, [project, source_repository]))
    end
    body = link_to truncate(h(event.target.proposal), :length => 100), [project, target_repository, event.target]
    category = "merge_request"
    [action, body, category]
  end

  def render_event_update_merge_request(event)
    source_repository = event.target.source_repository
    project = source_repository.project
    target_repository = event.target.target_repository

    action = action_for_event(:event_updated_merge_request) do
      link_to(h(target_repository.url_path) + " " + h("##{event.target.to_param}"),
        repo_owner_path(target_repository, :project_repository_merge_request_path, project, target_repository, event.target)) +
      "<div class=\"meta_body\">&#x2192; " + sanitize(event.data.to_s) + "</div>"
    end
    body = truncate(h(event.body), :length => 100)
    category = "merge_request"
    [action, body, category]
  end

  def render_event_reopen_merge_request(event)
    source_repository = event.target.source_repository
    project = source_repository.project
    target_repository = event.target.target_repository

    action = action_for_event(:event_reopened_merge_request) do
      "in " +
      link_to(h(project.title), project_path(project)) + "/" +
      link_to(h(source_repository.name), project_repository_url(project, source_repository))
    end
    body = link_to(truncate(h(event.target.proposal), :length => 100), [project, target_repository, event.target])
    category = "merge_request"
    [action, body, category]
  end


  def render_event_delete_merge_request(event)
    project = event.target.project

    action = action_for_event(:event_deleted_merge_request) do
      "from " + link_to(h(project.slug), project_path(project)) + "/" +
      link_to(h(target.name), project_repository_url(project, event.target))
    end
    category = "merge_request"
    [action, "", category]
  end

  def render_event_edit_wiki_page(event)
    project = event.target
    action = action_for_event(:event_updated_wiki_page) do
      link_to(h(project.slug), project_path(project)) + "/" +
      link_to(h(event.data), project_page_path(project, event.data))
    end
    category = "wiki"
    [action, "", category]
  end

  def render_event_push(event)
    event.single_commit? ? render_single_commit_push(event) : render_several_commit_push(event)
  end

  def render_single_commit_push(event)
    project = event.target.project
    commit = event.events.first
    repo = event.target
    commit_link = link_to(commit.data[0,8],
      project_repository_commit_path(project, repo, commit.data)
      )
    repo_link = link_to("#{repo_title(repo, project)}:#{event.data}",
      [project, repo])
    action = action_for_event(:event_pushed_n, :commit_link => commit_link) do
      "to #{repo_link}"
    end
    [action,"","push"]
  end

  def render_several_commit_push(event)
    project = event.target.project
    commit_link = link_to_if(event.has_commits?, pluralize(event.events.size, 'commit'),
      repo_owner_path(event.target, :project_repository_commits_in_ref_path,
        project, event.target, ensplat_path(event.data)),
      :id => "commits_in_event_#{event.to_param}_toggler",
      :class => "commit_event_toggler",
      "gts:url" => commits_event_path(event.to_param),
      "gts:id" => event.to_param)

    action = action_for_event(:event_pushed_n, :commit_link => commit_link) do
      title = repo_title(event.target, project)
      " to " + link_to(h(title+':'+event.data), repo_owner_path(event.target,
        :project_repository_commits_in_ref_path, project, event.target, ensplat_path(event.data)))
    end
    body = h(event.body)
    category = 'push'
    [action, body, category]
  end

  # Push events need to include information about their commits
  # - either a container for their commits (for Ajax loading)
  # - or the single commit included
  def render_commit_details_for_push_event(event)
    if event.single_commit?
      commit = event.events.first
      icon = avatar_from_email(commit.email, :size => 16)
      if commit.user
        actor = link_to(h(commit.actor_display), commit.user)
      else
        actor = h(commit.actor_display)
      end
      meta =  content_tag(:span,
        %Q{<span class="actor">#{actor}</span> } +
        %Q{<span class="timestamp">on #{commit.created_at.to_s(:long)}</span>})
      message = content_tag(:div, [icon, meta].join("\n"))
      commit_msg = link_to(simple_format(h(commit.body)),
        repo_owner_path(commit.target.target.target,
          :project_repository_commit_path, commit.project,
          commit.target.target.target, commit.data))
      body = content_tag(:div, commit_msg, :class => "commit_message")
      content_tag(:div, [message, body].join("\n"), :class => "event_instance")
    else
      img = image_tag("spinner.gif")
      content_tag(:div, img, :id => "commits_in_event_#{event.to_param}", :style => "display: none")
    end
  end

  def render_event_add_project_repository(event)
    action = action_for_event(:event_status_add_project_repository) do
      link_to(h(event.target.name), project_repository_path(event.project, event.target)) +
              " in " + link_to(h(event.project.title), project_path(event.project))
    end
    body = truncate(sanitize(event.target.description, :tags => %w[a em i strong b]), :length => 100)
    category = "repository"
    [action, body, category]
  end

  def render_event_add_favorite(event)
    favorite_class = event.body.constantize
    repo = favorite_class.find(event.data)
    action = action_for_event(:event_added_favorite) do
      link_to_watchable(repo)
      
    end
    body = event.body
    category = "favorite"
    [action, "", category]
  end
  protected
    def action_for_event(i18n_key, opts = {}, &block)
      header = "" + I18n.t("application_helper.#{i18n_key}", opts) + " "
      header + capture(&block)
    end

    def repo_title(repo, project)
      if repo.project_repo?
        h(File.join(project.to_param_with_prefix, repo.name))
      else
        h(File.join(repo.owner.to_param_with_prefix, project.slug, repo.name))
      end
    end
end
