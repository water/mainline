require "spork"
require "test/unit"

Spork.prefork do
  ENV["Rails.env"] = "test"
  require File.expand_path("../../config/environment", __FILE__)
  require "colorize"
  require "shoulda"
  require "factory_girl"
  require "rails/test_help"
  require "turn"
  require "factory_girl_rails"
  require "database_cleaner"
  
  DatabaseCleaner.strategy = :truncation
  
  require_relative "fixtures/oauth_test_consumer"
  require_relative "helpers/test_case"
end

Spork.each_run do
  DatabaseCleaner.clean
  FactoryGirl.reload
end