Gitorious::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false
  
  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # ActionMailer::Base.default_url_options[:protocol] = 'https'
  config.action_mailer.default_url_options = {
    :host => YAML.load_file(File.join(Rails.root, "config/gitorious.yml"))[Rails.env]["gitorious_host"]
  }
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.delivery_method = :test
  
  config.active_support.deprecation = :log
  
  config.logger = config.logger = Logger.new(Rails.root.join("log/test.log"), 50, 10**6)
  config.active_support.deprecation = :stderr 
end