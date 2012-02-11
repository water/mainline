# encoding: utf-8

class WebHookProcessor < ApplicationProcessor
  subscribes_to :web_hook_notifications
  attr_accessor :repository, :user

  def on_message(message)
    json = JSON.parse(message)
    begin
      self.user = User.find_by_login!(json["user"])
      self.repository = Repository.find(json["repository_id"])
      notify_web_hooks(json["payload"])#.with_indifferent_access)
    rescue ActiveRecord::RecordNotFound => e
      log_error(e.message)
    end
  end
  
  def notify_web_hooks(payload)
    repository.hooks.each do |hook|
      begin
        Timeout.timeout(10) do
          result = post_payload(hook, payload)
          if successful_response?(result)
            hook.successful_connection("#{result.code} #{result.message}")
          else
            hook.failed_connection("#{result.code} #{result.message}")
          end
        end
      rescue Errno::ECONNREFUSED
        hook.failed_connection("Connection refused")
      rescue Timeout::Error
        hook.failed_connection("Connection timed out")
      rescue SocketError
        hook.failed_connection("Socket error")
      end
    end
  end

  def successful_response?(response)
    case response
    when Net::HTTPSuccess, Net::HTTPMovedPermanently, Net::HTTPTemporaryRedirect, Net::HTTPFound
      return true
    else
      return false
    end
  end

  def post_payload(hook, payload)
    Net::HTTP.post_form(URI.parse(hook.url), {"payload" => payload.to_json})
  end

end
