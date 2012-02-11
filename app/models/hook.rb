# encoding: utf-8

class Hook < ActiveRecord::Base
  belongs_to :repository
  belongs_to :user

  validates_presence_of :repository, :user, :url
  validate :valid_url_format

  def successful_connection(message)
    self.successful_request_count += 1
    self.last_response = message
    save
  end

  def failed_connection(message)
    self.failed_request_count += 1
    self.last_response = message
    save
  end
  
  def valid_url_format
    begin
      uri = URI.parse(url)
      if uri.host.blank?
        errors.add(:url, "must be a valid URL")
      end
      if uri.scheme != "http"
        errors.add(:url, "must be a HTTP URL")
      end
    rescue URI::InvalidURIError
      errors.add(:url, "must be a valid URL")
    end
  end
end
