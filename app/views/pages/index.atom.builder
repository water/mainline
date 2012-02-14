# encoding: utf-8

atom_feed do |feed|
  feed.title("#{h(@project.title)} Wiki changes")
  feed.updated((@commits.blank? ? nil : @commits.first.committed_date))
	
  @commits.each do |commit|
    # TODO: we only find the first page changed for now:
    first_page = commit.diffs.first.a_path.split(".").first
    item_url = history_project_page_path(@project, first_page, :html) rescue project_pages_path(@project, :html)
    feed.entry(commit, {
      :url => item_url, 
      :updated => commit.committed_date.utc, 
      :published => commit.committed_date.utc
    }) do |entry|
      entry.title(truncate(commit.message, :length => 100))
      entry.content(<<-EOS, :type => 'html')
<p>#{h(commit.author.name)} changed page #{h(first_page)}</p>

<pre>
#{commit.diffs.map{|d| d.diff }.join("\n")}
<pre>

EOS
      entry.author do |author|
        author.name(commit.author.name)
      end
    end
  end
end