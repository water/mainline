# encoding: utf-8

module UsersHelper
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




end
