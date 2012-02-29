Gitorious::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Specifies the header that your server uses for sending files
  config.action_dispatch.x_sendfile_header = "X-Sendfile"

  # For nginx:
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'

  # If you have no front-end server that supports something like X-Sendfile,
  # just comment this out and Rails will serve the files

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Disable Rails's static asset server
  # In production, Apache or nginx will already do this
  config.serve_static_assets = false

  # Enable serving of images, stylesheets, and javascripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!
  
  # Compress JavaScript and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true
  
  config.action_controller.page_cache_directory = cache_dir
  #config.action_controller.cache_store = :file_store, File.join(cache_dir, "fragments")
  config.cache_store = :mem_cache_store, "localhost"

  #
  # If you don't have outgoing email set up, uncomment the following two lines:
  # config.action_mailer.delivery_method = :test
  # config.action_mailer.raise_delivery_errors = false
  config.action_mailer.delivery_method = :sendmail

  config.action_mailer.default_url_options = {
    :host => YAML.load_file(File.join(Rails.root, "config/gitorious.yml"))[Rails.env]["gitorious_host"]
  }
  # ActionMailer::Base.default_url_options[:protocol] = 'https'
  # Disable delivery errors, bad email addresses will be ignored
  config.after_initialize do
    #ExceptionNotifier.exception_recipients = YAML.load_file(File.join(Rails.root, "config/gitorious.yml"))[Rails.env]["exception_notification_emails"]
    #ExceptionNotifier.class_eval do
      #ExceptionNotifier.template_root = "#{Rails.root}/vendor/plugins/exception_notification/lib/../views"
    #end
end
