# encoding: utf-8

module FavoritesHelper
  def favorite_button(watchable)
    if logged_in? && favorite = current_user.favorites.detect{|f| f.watchable == watchable}
      link = destroy_favorite_link_to(favorite, watchable)
    else
      link = create_favorite_link_to(watchable)
    end

    content_tag(:div, link, :class => "repository-link favorite button")
  end

  def create_favorite_link_to(watchable)
    class_name = watchable.class.name
    link_to("Start watching",
      favorites_path(:watchable_id => watchable.id,:watchable_type => class_name),
      :method => :post, :"data-request-method" => "post",
      :class => "watch-link disabled round-10",
      :id => "watch_#{class_name.downcase}_#{watchable.id}"
      )
  end

  def destroy_favorite_link_to(favorite, watchable, options = {})
    label = options[:label] || "Stop watching"
    link_to(label, favorite_path(favorite),
      :method => :delete, :"data-request-method" => "delete",
      :class => "watch-link enabled round-10")
  end

  def link_to_notification_toggle(favorite)
    link_classes = %w[toggle round-10]
    link_classes << (favorite.notify_by_email? ? "enabled" : "disabled")
    link = link_to(favorite.notify_by_email? ? "on" : "off", favorite,
      :class => link_classes.join(" "))
    content_tag(:div, link,
            :class => "white-button round-10 small-button update favorite")
  end

  def link_to_unwatch_favorite(favorite)
    link = link_to("Unwatch", favorite, :class => "watch-link enabled round-10")
    content_tag(:div, link,
      :class => "white-button round-10 small-button favorite")
  end

  # Builds a link to the target of a favorite event
  def link_to_watchable(watchable)
    case watchable
    when Repository
      link_to(repo_title(watchable, watchable.project),
        repo_owner_path(watchable, [watchable.project, watchable]))
    when MergeRequest
      link_to(h(truncate(watchable.summary, :length => 65)),
        repo_owner_path(watchable.target_repository,
          [watchable.source_repository.project,
           watchable.target_repository,
          watchable]))
    else
      link_to(h(watchable.title), watchable)
    end
  end

  # is this +watchable+ included in the users @favorites?
  def favorited?(watchable)
    @favorites.include?(watchable)
  end

  def css_class_for_watchable(watchable)
    watchable.class.name.underscore
  end

  def css_classes_for(watchable)
    css_classes = ["favorite"]
    css_classes << css_class_for_watchable(watchable)
    if current_user == watchable.user
      css_classes << "mine"
    else
      css_classes << "foreign"
    end
    css_classes.join(" ")
  end
end
