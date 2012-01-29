require "spork"

Spork.prefork do
  ENV["Rails.env"] = "test"
  require File.expand_path('../../config/environment', __FILE__)
  require "colorize"
  require "shoulda"
  require "factory_girl"
  require 'rails/test_help'
  require 'turn'
  require_relative "fixtures/oauth_test_consumer"
  
  class ActiveSupport::TestCase
    # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
    #
    # Note: You'll currently still have to declare fixtures explicitly in integration tests
    # -- they do not yet inherit this setting
    fixtures :all

    # Add more helper methods to be used by all tests here...

    def find_message_with_queue_and_regexp(queue_name, regexp)
      ActiveMessaging::Gateway.connection.clear_messages
      yield
      msg = ActiveMessaging::Gateway.connection.find_message(queue_name, regexp)
      assert_not_nil msg, "Message #{regexp.source} in #{queue_name} was not found"
      return ActiveSupport::JSON.decode(msg.body)
    end
  
    def repo_path
      File.join(File.dirname(__FILE__), "..", ".git")
    end
  
    def grit_test_repo(name)
      File.join(Rails.root, "vendor/grit/test", name )
    end
  
    def assert_incremented_by(obj, meth, value)
      value_before = obj.send(meth)
      yield
      value_after = obj.send(meth)
      error_msg = (value_before == value_after) ? "unchanged" : "incremented by #{(value_after - value_before)}"
      assert_equal(value, (value_after - value_before), "#{obj}##{meth} should be incremented by #{value} but was #{error_msg}")
    end

    def assert_includes(collection, object, message=nil)
      assert(collection.include?(object),
        (message || inclusion_failure(collection, object, true)))
    end

    def assert_not_includes(collection, object, message=nil)
      assert(!collection.include?(object),
        (message || inclusion_failure(collection, object, false)))
    end

    def inclusion_failure(collection, object, should_be_included)
      not_message = should_be_included ? "" : " not"
      "Expected collection (#{collection.count} items) #{not_message} to include #{object.class.name}"
    end

    def self.should_render_in_global_context(options = {})
      should "Render in global context for actions" do
        filter = @controller.class._process_action_callbacks.find {|c|
          c.raw_filter == :require_global_site_context
        }
        assert_not_nil filter, ":require_global_site_context before_filter not set"
        unless options[:except].blank?
          assert_not_nil filter.options[:except], "no :except specified in controller"
          assert_equal [*options[:except]].flatten.map(&:to_s).sort, filter.options[:except].sort
        end
        unless options[:only].blank?
          assert_not_nil filter.options[:only], "no :only specified in controller"
          assert_equal [*options[:only]].flatten.map(&:to_s).sort, filter.options[:only].sort
        end
      end
    end
  
    def self.should_render_in_site_specific_context(options = {})
      should "Render in site specific context for actions" do
        filter = @controller.class._process_action_callbacks.find {|c|
          c.raw_filter == :redirect_to_current_site_subdomain
        }
        assert_not_nil filter, ":redirect_to_current_site_subdomain before_filter not set"
        unless options[:except].blank?
          assert_not_nil filter.options[:except], "no :except specified in controller"
          assert_equal [*options[:except]].flatten.map(&:to_s).sort, filter.options[:except].sort
        end
        unless options[:only].blank?
          assert_not_nil filter.options[:only], "no :only specified in controller"
          assert_equal [*options[:only]].flatten.map(&:to_s).sort, filter.options[:only].sort
        end
      end
    end

    # Makes Rails.cache yield always.
    # Rails.cache.stubs(:fetch).yields won't do. That will not make the block
    # return what it originally returned.
    def rails_cache_passthrough
      Rails.cache.stubs(:fetch)
      class << Rails.cache
        def fetch(*args)
          yield
        end
      end
    end
  end

  class ActiveMessaging::Adapters::Test::Connection
    # For easier testing.
    def clear_messages
      destinations.each {|d| d.messages.clear }
    end
  end

  class ActionController::TestCase
    include AuthenticatedTestHelper

    def self.without_ssl_context
      context "without ssl" do
        setup { @request.env.delete("HTTPS") }
        context("") { yield }
      end
    end

    def self.with_ssl_context
      context "without ssl" do
        setup { @request.env["HTTPS"] = "on" }
        context("") { yield }
      end
    end

    def self.should_redirect_to_ssl
      should 'redirect to ssl' do
        # TODO Fix this!
        assert_redirected_to "https://" + @request.host + @request.request_uri
      end
    end
  end
end

Spork.each_run do
  # FactoryGirl.reload <= Makes tests about 30% slower
end