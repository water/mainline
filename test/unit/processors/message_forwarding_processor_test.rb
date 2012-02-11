# encoding: utf-8
require File.dirname(__FILE__) + '/../../test_helper'

class MessageForwardingProcessorTest < ActiveSupport::TestCase
  
  def setup
    @processor = MessageForwardingProcessor.new
    @sender = users(:moe)
    @recipient = users(:mike)
    @message = messages(:johans_message_to_moe)
  end
  
  def teardown
    @processor = nil
  end  

  should 'increment the number of deliveries by one when receiving a message' do
    json_hash = {:sender_id => @sender.id, :recipient_id => @recipient.id, :subject => "Hello world", :body => "This is just ridiculous", :message_id => @message.id}
    assert_incremented_by(ActionMailer::Base.deliveries, :size, 1) do
      @processor.on_message(json_hash.to_json)
    end
  end
  
  should 'not deliver email if sender or recipient cannot be found' do
    json_hash = {:sender_id => @sender.id, :recipient_id => @recipient.id + 999, :subject => "Hello world", :body => "This is just ridiculous", :message_id => @message.id}
    assert_incremented_by(ActionMailer::Base.deliveries, :size, 0) do
      @processor.on_message(json_hash.to_json)
    end
  end
end