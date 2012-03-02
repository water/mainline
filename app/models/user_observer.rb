# encoding: utf-8

class UserObserver < ActiveRecord::Observer
  def after_create(user)
    return # TODO: Temporary fix
    Mailer.signup_notification(user).deliver if user.identity_url.blank?
  end

  def after_save(user)
    return # TODO: Temporary fix
    Mailer.activation(user).deliver if user.recently_activated?  
  end
end
