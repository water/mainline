# encoding: utf-8

require 'test_helper'

class HookTest < ActiveSupport::TestCase
  should_belong_to :repository
  should_validate_presence_of :user, :repository, :url

  context "URL validation" do
    should "require a valid URL" do
      hook = Hook.new(:url => "http:/gitorious.org/web-hooks")
      assert !hook.valid?
      assert_not_nil hook.errors.on(:url)
    end

    should "require http URLs" do
      hook = Hook.new(:url => "https://gitorious.org/web-hooks")
      assert !hook.valid?
      assert_not_nil hook.errors.on(:url)
    end
  end

  context "Keeping track of connection attempts" do
    setup {
      @repository = repositories(:johans)
      @user = users(:johan)
      @hook = @repository.hooks.create :url => "http://gitorious.org/web-hooks"
    }

    should "increment a counter of invalid responses when an error occurs" do
      assert_equal 0, @hook.failed_request_count.to_i
      @hook.failed_connection "302 Moved Permanently"
      assert_equal 1, @hook.failed_request_count
    end

    should "increment successful_request_count when a successful response is received" do
      assert_equal 0, @hook.successful_request_count.to_i
      @hook.successful_connection "200 OK"
      assert_equal 1, @hook.successful_request_count
      assert_equal "200 OK", @hook.last_response
    end
  end
end
