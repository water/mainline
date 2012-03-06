# encoding: utf-8

class Mailer < ActionMailer::Base
  include ActionView::Helpers::SanitizeHelper
  extend ActionView::Helpers::SanitizeHelper::ClassMethods

  def signup_notification(user)
    setup_email(user)
    @subject    += I18n.t "mailer.subject"
    @body[:url]  = url_for(
      :controller => 'users',
      :action => 'activate',
      :activation_code => user.activation_code
    )
  end

  def activation(user)
    setup_email(user)
    @subject    += I18n.t "mailer.activated"
  end

  def notification_copy(recipient, sender, subject, body, notifiable, message_id)
    @recipients       =  recipient.email
    @from             = "Gitorious Messenger <no-reply@#{GitoriousConfig['gitorious_host']}>"
    @subject          = "New message: " + sanitize(subject)
    @body[:url]       = url_for({
        :controller => 'messages',
        :action => 'show',
        :id => message_id,
        :host => GitoriousConfig['gitorious_host']
      })

    @body[:contents]      = sanitize(body)
    if '1.9'.respond_to?(:force_encoding)
      @body[:recipient] = recipient.title.to_s.force_encoding("utf-8")
      @body[:sender]    = sender.title.to_s.force_encoding("utf-8")
    else
      @body[:recipient] = recipient.title.to_s
      @body[:sender]    = sender.title.to_s
    end
    if notifiable
      @body[:notifiable_url] = build_notifiable_url(notifiable)
    end
  end

  def forgotten_password(user, password_key)
    setup_email(user)
    @subject += I18n.t "mailer.new_password"
    @body[:url] = reset_password_url(password_key)
    @user = user
  end

  def new_email_alias(email)
    @from       = "Gitorious <no-reply@#{GitoriousConfig['gitorious_host']}>"
    @subject    = "[Gitorious] Please confirm this email alias"
    @sent_on    = Time.now
    @recipients = email.address
    @body[:email] = email
    @body[:url] = confirm_user_alias_url(email.user, email.confirmation_code)
  end

  def message_processor_error(processor, err, message_body)
      subject     "[Gitorious Processor] fail in #{processor.class.name}"
      from        "Gitorious <no-reply@#{GitoriousConfig['gitorious_host']}>"
      recipients  GitoriousConfig['exception_notification_emails']
      body        :error => err, :message => message_body, :processor => processor
  end

  def favorite_notification(user, notification_body)
    setup_email(user)
    @subject += "Activity: #{notification_body[0,35]}..."
    @body[:user] = user
    @body[:notification_body] = notification_body
    @user        = user
  end

  protected
    def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = "Gitorious <no-reply@#{GitoriousConfig['gitorious_host']}>"
      @subject     = "[Gitorious] "
      @sent_on     = Time.now
      @body[:user] = user
      @user        = user
    end

end
