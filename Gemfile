source "http://rubygems.org"

gem "rails", "3.0.10"
gem "chronic"
gem "geoip"
gem "hoe", :require => false
gem "echoe", :require => false
gem "ruby-yadis", :require => "yadis"
gem "rdiscount", "1.3.1.1"
gem "mime-types", :require => "mime/types"
gem "diff-lcs", :require => "diff/lcs"
gem "state_machine"
gem "riddle" # For the ultrasphinx plugin
gem "rdoc"
gem "exception_notification", :git => "git://github.com/smartinez87/exception_notification.git"

# Authentication
gem "rack-openid"
gem "ruby-openid", "2.1.8", :require => "openid"
gem "oauth", "0.4.4"
gem "oauth2"

# Database
gem "mysql"

# View
gem "will_paginate"
gem "builder"
gem "paperclip", :git => "git://github.com/thoughtbot/paperclip.git"

# Background
gem "activemessaging", :git => "git://github.com/kookster/activemessaging.git"
gem "daemons", :require => false
gem "beanstalk-client"

group :development do
  gem "hirb"
  gem "ruby-debug19"
  gem "colorize"
  gem "foreman"
end

group :test do
  gem "spork-testunit"
  gem "spork", "~> 1.0rc"
  gem "mocha", :require => false
  gem "factory_girl", :git => "http://github.com/thoughtbot/factory_girl.git", :require => false
  gem "shoulda", :git => "git://github.com/bmaddy/shoulda.git", :branch => "rails3", :require => false
end