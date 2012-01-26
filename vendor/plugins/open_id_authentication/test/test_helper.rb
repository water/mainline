require 'test/unit'
require 'rubygems'

gem 'activesupport'
require 'active_support'

gem 'actionpack'
require 'action_controller'

gem 'mocha'
require 'mocha'

gem 'ruby-openid'
require 'openid'

Rails.root = File.dirname(__FILE__) unless defined? Rails.root
require File.dirname(__FILE__) + "/../lib/open_id_authentication"
