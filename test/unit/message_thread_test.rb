# encoding: utf-8
require_relative "../test_helper"

class MessageThreadTest < ActiveSupport::TestCase
  context 'Building a message' do
    setup do
      @sender = Factory.create(:user)
      @john = Factory.create(:user, :login => 'john')
      @jane = Factory.create(:user, :login => 'jane')
      @thread = MessageThread.new(:subject => 'Hello world', :body => 'Lorem ipsum', :recipients => 'john jane', :sender => @sender)
    end
    
    should 'extract two recipients' do
      assert_equal(2, @thread.recipients.size)
    end
    
    should 'assign a User object as sender' do
      assert_kind_of User, @thread.sender
    end
    
    should 'have a size accessor' do
      assert_equal 2, @thread.size
    end
    
    should 'generate n messages' do
      assert_equal(2, @thread.messages.size)
    end
    
    should 'return a boolean indicating whether all messages were saved' do
      assert_incremented_by Message, :count, 2 do
        assert @thread.save
      end
    end
    
    should 'have a title' do
      assert_equal("2 messages", @thread.title)
    end
    
    should 'behave like an enumerable' do
      @thread.each{|msg| assert_kind_of(Message, msg)}
      assert_kind_of Message, @thread.first
    end
    
    should 'return a Message object with a string of recipients set' do
      result = @thread.message
      assert_equal('john,jane', result.recipients)
    end
  end
end