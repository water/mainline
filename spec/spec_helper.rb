require "spork"
require "factory_girl"
require "test/unit"
if RUBY_PLATFORM =~ /darwin/
  require "spork/ext/ruby-debug"
end

ENV["RAILS_ENV"] ||= "test"
abort("RAILS_ENV != test") unless ENV["RAILS_ENV"] == "test"

Spork.prefork do
  require File.expand_path("../../config/environment", __FILE__)
  require "rspec/rails"
  require "rspec/autorun"
  require "capybara/rails"
  require "database_cleaner"
  
  Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

  RSpec.configure do |config|
    config.mock_with :rspec
    config.use_transactional_fixtures = false
    config.before(:suite) { DatabaseCleaner.strategy = :truncation }
    config.before(:each) { DatabaseCleaner.start }
    config.after(:each) { DatabaseCleaner.clean }
    config.after(:each) { teardown }
    config.infer_base_class_for_anonymous_controllers = false
    config.mock_with :rspec
    config.include Factory::Syntax::Methods
    config.include LoginHelper
    config.include UrlHelper
    config.include SetupHelper
    config.order = "random"
  end
end

Spork.each_run do
  ActiveRecord::Base.instantiate_observers
  load "#{Rails.root}/config/routes.rb"
  Dir["#{Rails.root}/app/**/*.rb"].each { |f| load f }
  
  FactoryGirl.factories.clear 
  FactoryGirl.sequences.clear
  FactoryGirl.traits.clear
  load "#{::Rails.root}/spec/factories.rb"
end
