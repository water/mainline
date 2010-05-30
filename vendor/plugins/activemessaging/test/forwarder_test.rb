require File.dirname(__FILE__) + '/test_helper'
require 'rubygems'
require 'mocha'
require 'activemessaging/forwarder'

class ForwarderTest < Test::Unit::TestCase

  def setup
    @forwarder = ActiveMessaging::Forwarder.new
    ActiveMessaging::Gateway.store_and_forward_to :test
    ActiveMessaging::Gateway.destination :hello_world, '/queue/helloWorld' rescue nil
    ActiveMessaging::StoredMessage.delete_all
  end
  
  def test_publish_should_check_and_resend_queued_messages
    ActiveMessaging::StoredMessage.store!("hello_world", "hello, world", {:keep_it => "real"})
    ActiveMessaging::Gateway.connection('default').expects(:send)
    @forwarder.forward ActiveMessaging::StoredMessage.find(:first)
  end

  def test_check_and_resend_should_empty_the_queue
    ActiveMessaging::StoredMessage.store!("hello_world", "hello, world", {:keep_it => "real"})
    @forwarder.check_and_resend_queued
    assert_equal 0, ActiveMessaging::StoredMessage.count_undelivered
  end
  
  def test_should_not_destroy_message_when_delivery_failed
    stored_message = ActiveMessaging::StoredMessage.store!("hello_world", "hello, world", {:keep_it => "real"})
    ActiveMessaging::Gateway.expects(:deliver_message).raises(Timeout::Error, "timed out")
    stored_message.expects(:destroy).never
    begin
      @forwarder.forward(stored_message)
    rescue Timeout::Error
    end
  end
  
  def test_should_mark_the_message_as_flagged_before_forwarding
    message = ActiveMessaging::StoredMessage.store!("hello_world", "hello, world", {:keep_it => "real"})
    message.stubs(:reload)
    ActiveMessaging::StoredMessage.stubs(:find).returns(message).returns(nil)
    message.expects(:active!)
    @forwarder.forward message
  end
  
  def test_should_not_deliver_a_delivered_message
    message = ActiveMessaging::StoredMessage.store!("hello_world", "hello, world", {:keep_it => "real"})
    message.delivered!
    message.expects(:delivered!).never
    @forwarder.forward message
  end
  
  def test_should_not_mark_as_active_when_active
    message = ActiveMessaging::StoredMessage.store!("hello_world", "hello, world", {:keep_it => "real"})
    message.active!
    message.expects(:active!).never
    @forwarder.forward message
  end
  
  def test_should_mark_as_inactive_when_delivery_fails
    message = ActiveMessaging::StoredMessage.store!("hello_world", "hello, world", {:keep_it => "real"})
    ActiveMessaging::Gateway.expects(:deliver_message).raises(Timeout::Error, "timed out")
    begin
      @forwarder.forward(message)
    rescue Timeout::Error
    end
    assert_equal false, message.reload.active?
  end
end