# encoding: utf-8

class UserObserver < ActiveRecord::Observer
  def after_create(user)
    Mailer.deliver_signup_notification(user) if user.identity_url.blank?
  end

  def after_save(user)
    Mailer.deliver_activation(user) if user.recently_activated?  
  end
end
