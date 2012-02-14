# encoding: utf-8

atom_feed do |feed|
  feed.title("Gitorious: #{h(@repository.gitdir)}:#{h(desplat_path(params[:branch]))}")
  feed.updated((@commits.blank? ? nil : @commits.first.committed_date))
	
  @commits.each do |commit|
    item_url = "http://#{GitoriousConfig['gitorious_host']}"
    item_url << repo_owner_path(@repository, :project_repository_commit_path, 
                                @project, @repository, commit.id, :html)
    feed.entry(commit, {
      :url => item_url, 
      :updated => commit.committed_date.utc, 
      :published => commit.committed_date.utc
    }) do |entry|
      entry.title(truncate(commit.message, :length => 100))
      entry.content(<<-EOS, :type => 'html')
<h2>In #{@repository.gitdir}:#{h(@ref)}</h2>

<ul>
  <li><strong>Commit:</strong> #{link_to(commit.id, item_url)}</li>
  <li><strong>Date:</strong> #{commit.committed_date.utc.strftime("%Y-%m-%d %H:%M")}</li>
  <li><strong>Author:</strong> #{commit.author.name}</li>
  <li><strong>Committer:</strong> #{commit.committer.name}</li>
</ul>

<pre>
#{h word_wrap(commit.message)}
<pre>

EOS
      entry.author do |author|
        author.name(commit.author.name)
      end
    end
  end
end