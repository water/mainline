# encoding: utf-8

atom_feed do |feed|
  feed.title("Gitorious: #{@repository.url_path} merge requests")
  feed.updated((@open_merge_requests.blank? ? Time.now : @open_merge_requests.first.created_at))

  @open_merge_requests.each do |mr|
    item_url = url_for(:overwrite_params => {
        :action => "show",
        :id => mr.to_param,
        :format => nil
      }, :only_path => false)
    feed.entry(mr, :url => item_url) do |entry|
      entry.title("##{h(mr.id)}: " + h(mr.summary))
      entry.content((<<-EOS), :type => "html")
<strong>#{h(mr.summary)}</strong><br /><br />
#{h(mr.proposal)}
<hr />
Status: #{h(mr.status_tag.to_s)}
EOS
      entry.author do |author|
        author.name(mr.user.login)
      end
    end
  end
end
