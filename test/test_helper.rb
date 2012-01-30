require "spork"

Spork.prefork do
  ENV["Rails.env"] = "test"
  require File.expand_path("../../config/environment", __FILE__)
  require "colorize"
  require "shoulda"
  require "factory_girl"
  require "rails/test_help"
  require "turn"
  require "factory_girl_rails"
  
  require_relative "fixtures/oauth_test_consumer"
  require_relative "helpers/test_case"
end

Spork.each_run do
  # FactoryGirl.reload <= Makes tests about 30% slower
end