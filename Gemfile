source 'http://rubygems.org'

gem 'rails', '3.1.0'
gem "mysql2",     "~> 0.3.7"

# Bundle edge Rails instead:
#gem 'rails', :git => 'git://github.com/rails/rails.git'

# gem 'sqlite3-ruby', :require => 'sqlite3'

gem "chronic"
gem "geoip"
gem "daemons", :require => false
gem "hoe", :require => false
gem "echoe", :require => false
gem "ruby-yadis", :require => "yadis"
gem "ruby-openid", :require => "openid"
gem "rdiscount", "1.3.1.1"
gem "stomp", "1.1"
gem "mime-types", :require => "mime/types"
gem "diff-lcs", :require => "diff/lcs"
gem "oauth"
gem "paperclip", :git => "git://github.com/thoughtbot/paperclip.git"
gem "state_machine"
gem "riddle" # For the ultrasphinx plugin
gem "builder"
gem "will_paginate"
gem "rdoc"
gem "ultrasphinx"
gem "exception_notification", git: "git://github.com/smartinez87/exception_notification.git"
# group :development do
#   gem "mongrel", :git => "http://github.com/engineyard/mongrel.git"
# end


if RUBY_VERSION < '1.9'
  gem "json"
end

gem "mysql"

group :test do
  gem "mocha", :require => false
  # Required manaully in the test_helper, see http://github.com/thoughtbot/factory_girl/commit/feac7298352a83fef0717d8beadd2eda9aabfe56
  gem "factory_girl", :git => "http://github.com/thoughtbot/factory_girl.git", :require => false
  # Same goes for shoulda
  gem "shoulda", :git => "git://github.com/bmaddy/shoulda.git", :branch => "rails3", :require => false
end
