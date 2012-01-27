require File.dirname(__FILE__) + '/test_helper'
require 'activemessaging/trace_filter'

module ActiveMessaging #:nodoc:
  def self.reload_activemessaging
  end
end

class TestProcessor < ActiveMessaging::Processor
  def on_message message
  end
end

class TestSender < ActiveMessaging::Processor
end

class FakeMessage < ActiveMessaging::BaseMessage
  def initialize
    super("Ni hao ma?", 1, {'destination'=>'/queue/helloWorld'}, '/queue/helloWorld')
  end
end

class TracerTest < Test::Unit::TestCase
  include ActiveMessaging::TestHelper

  def setup
    ActiveMessaging::Gateway.define do |s|
      s.queue :hello_world, '/queue/helloWorld'
      s.queue :trace, '/queue/trace'

      s.filter :trace_filter, :queue=>:trace
    end
    
    TestProcessor.subscribes_to :hello_world
    TestSender.publishes_to :hello_world
  end

  def teardown
    ActiveMessaging::Gateway.reset
  end

  def test_should_trace_sent_messages
    message = "Ni hao ma?"

    sender = TestSender.new
    sender.publish :hello_world, message
    
    assert_message :trace, "<sent><from>TestSender</from><queue>hello_world</queue><message>#{message}</message></sent>"
    assert_message :hello_world, message
  end

  def test_should_trace_received_messages
    ActiveMessaging::Gateway.dispatch FakeMessage.new

    assert_message :trace, "<received><by>TestProcessor</by><queue>hello_world</queue><message>Ni hao ma?</message></received>"
  end
end