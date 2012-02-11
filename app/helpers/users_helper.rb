# encoding: utf-8

module UsersHelper
  include FavoritesHelper
  include MessagesHelper
  def encoded_mail_to(email)
    mail_to(email, nil, :replace_at => "AT@NOSPAM@",
      :replace_dot => "DOT", :encode => "javascript")
  end

  def encoded_mail(email)
    email = email.gsub(/@/,"AT@NOSPAM@")
    email.gsub(/\./,"DOT")
  end

  def mangled_mail(email)
    user, domain = h(email).split("@", 2)
    return user if domain.blank?
    domain, ext = domain.split(".", 2)
    [user, " @", domain[0, domain.length/2],
     "&hellip;", domain[-(domain.length/3)..-1], ".#{ext}"].map {|s|
      s.html_safe
    }.join
  end

  def render_email(email)
    encoded_email = if GitoriousConfig["mangle_email_addresses"]
                      mangled_mail(email.to_s)
                    else
                      h(email.to_s)
                    end
    "&lt;" + encoded_email.to_s + "&gt;"
  end

  def is_current_user?(a_user)
    logged_in? && current_user == a_user
  end

  def show_merge_request_count_for_user?(a_user)
    is_current_user?(a_user) &&
         !a_user.review_repositories_with_open_merge_request_count.blank?
  end

  def personified(user, current_user_msg, other_user_msg)
    is_current_user?(user) ? h(current_user_msg) : h(other_user_msg)
  end

  def favorites_heading_for(user)
    personified(user, "You are watching", "#{user.login} is watching")
  end

  def no_watchings_notice_for(user)
    msg = personified(user, "You aren't", "#{user.login} isn't") +
      " watching anything yet."
    if is_current_user?(user)
      msg << "Click the watch icon to get events feeded into this page"
    end
    msg
  end

  def showing_newsfeed?
    is_current_user?(@user) && params[:events] != "outgoing"
  end

  def newsfeed_or_user_events_link
    if showing_newsfeed?
      link_to "Show my activities", user_path(@user, {:events => "outgoing"})
    else
      link_to "Show my newsfeed", user_path(@user)
    end
  end
end
