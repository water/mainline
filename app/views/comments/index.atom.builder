# encoding: utf-8

atom_feed do |feed|
  feed.title("Gitorious: #{@repository.name} comments")
  feed.updated((@comments.blank? ? Time.now : @comments.first.created_at))

  @comments.each do |comment|
    item_url = "http://#{GitoriousConfig['gitorious_host']}" + project_repository_comments_path(@project,@repository)
    feed.entry(comment, :url => item_url) do |entry|
      entry.title("#{comment.user.login}: #{truncate(comment.body, :length => 30)}")
      entry.content(comment.body)
      entry.author do |author|
        author.name(comment.user.login)
      end
    end
  end
end