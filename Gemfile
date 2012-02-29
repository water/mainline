source "http://rubygems.org"

gem "rails", "3.1.3"
gem "chronic"
gem "geoip"
gem "hoe", :require => false
gem "echoe", :require => false
gem "ruby-yadis", :require => "yadis"
gem "rdiscount" # , "1.3.1.1"
gem "mime-types", :require => "mime/types"
gem "diff-lcs", :require => "diff/lcs"
gem "state_machine"
gem "riddle" # For the ultrasphinx plugin
gem "rdoc"
gem "exception_notification", :git => "git://github.com/smartinez87/exception_notification.git"
gem "gash", git: "git://github.com/water/gash.git"

gem 'rails-dev-tweaks', '~> 0.6.1'

# Authentication
gem "rack-openid"
gem "ruby-openid", "2.1.8", :require => "openid"
gem "oauth", "0.4.4"
gem "oauth2"

# Database
gem "mysql2", "0.3.10"
gem "citier", git: "git://github.com/water/citier.git"

# View
gem "will_paginate"
gem "builder"
gem "paperclip", :git => "git://github.com/thoughtbot/paperclip.git"
gem "rails_autolink"
gem "spine-rails"

group :assets do
  gem 'sass-rails', " ~> 3.1.0"
  gem 'haml-rails'
  gem 'coffee-rails', " ~> 3.1.0"
  gem 'uglifier'
  gem 'less-rails-bootstrap'
end

gem 'jquery-rails'

# Background
gem "activemessaging", :git => "git://github.com/kookster/activemessaging.git"
gem "daemons", :require => false
gem "beanstalk-client"
gem "gash", git: "git://github.com/water/gash.git"

group :development do
  gem "hirb"
  gem "ruby-debug19"
  gem "colorize"
  gem "foreman"
end

group :test do
  gem "spork-testunit"
  gem "term-ansicolor"
  gem "factory_girl_rails"
  gem "minitest"
  gem "spork", "0.9.0"
  gem "mocha", require: false
  gem "shoulda", :git => "git://github.com/bmaddy/shoulda.git", :branch => "rails3", :require => false  
  gem "rspec"
  gem "capybara"
  gem "launchy"
  gem "selenium"
  gem "rspec-rails"
  gem "turn"
  gem "database_cleaner"
end