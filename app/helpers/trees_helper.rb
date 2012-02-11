
# encoding: utf-8

module TreesHelper
  include RepositoriesHelper

  MAX_TREE_ENTRIES_FOR_LAST_COMMIT_LOG = 15

  def current_path
    @path.dup
  end

  def tree_archive_status_url
    fmt = (params[:archive_format] == "tar.gz" ? "tar" : zip)
    self.send("project_repository_archive_#{fmt}_path",
      @repository.project, @repository, @ref, :format => :js)
  end

  def build_tree_path(path)
    current_path << path
  end

  def breadcrumb_path(root_name = "root", commit_id = @ref)
    out = %Q{<ul class="path_breadcrumbs">\n}
    visited_path = []
    out <<  %Q{  <li>/ #{link_to(root_name, tree_path(commit_id, []))}</li>\n}
    current_path.each_with_index do |path, index|
      visited_path << path
      if visited_path == current_path
        out << %Q{  <li>/ #{path}</li>\n}
      else
        out << %Q{  <li>/ #{link_to(path, tree_path(commit_id, visited_path))}</li>\n}
      end
    end
    out << "</ul>"
    out
  end

  def render_tag_box_if_match(sha, tags_per_sha)
    tags = tags_per_sha[sha]
    return if tags.blank?
    out = ""
    tags.each do |tagname|
      out << %Q{<span class="tag"><code>}
      out << tagname
      out << %Q{</code></span>}
    end
    out
  end

  def commit_for_tree_path(repository, path)
    repository.commit_for_tree_path(@ref, @commit.id, path)
  end

  def too_many_entries_for_log?(tree)
    tree.contents.length >= MAX_TREE_ENTRIES_FOR_LAST_COMMIT_LOG
  end
end
