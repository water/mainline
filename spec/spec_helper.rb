require "spork/ext/ruby-debug"
ENV["RAILS_ENV"] ||= "test"
abort("RAILS_ENV != test") unless ENV["RAILS_ENV"] == "test"

Spork.prefork do
  require File.expand_path("../../config/environment", __FILE__)
  require "rspec/rails"
  require "rspec/autorun"
  require "./spec/helpers/helper_methods"
  require "capybara/rails"
  require "database_cleaner"
  
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  RSpec.configure do |config|
    config.fixture_path = "#{::Rails.root}/spec/fixtures"
    config.use_transactional_fixtures = false
    config.before(:suite) { DatabaseCleaner.strategy = :truncation }
    config.before(:each) { DatabaseCleaner.start }
    config.after(:each) { DatabaseCleaner.clean }
    config.infer_base_class_for_anonymous_controllers = false
    config.include Factory::Syntax::Methods
  end
end

Spork.each_run do
  FactoryGirl.factories.clear 
  FactoryGirl.find_definitions
end