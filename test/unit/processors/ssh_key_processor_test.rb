# encoding: utf-8


require File.dirname(__FILE__) + '/../../test_helper'

class SshKeyProcessorTest < ActiveSupport::TestCase

  def setup
    SshKey.any_instance.stubs(:valid_key_using_ssh_keygen?).returns(true)
    @processor = SshKeyProcessor.new
    @key = FactoryGirl.create(:ssh_key, :ready => false)
  end
  
  should "add to authorized keys" do
    assert !@key.ready?
    SshKey.expects(:add_to_authorized_keys).with('fofofo')
    options = {
      :target_class => 'SshKey', 
      :command => 'add_to_authorized_keys', 
      :arguments => ['fofofo'],
      :target_id => @key.id}
    json = options.to_json
    @processor.on_message(json)
    assert @key.reload.ready?
  end
  
  should "remove from authorized keys" do
    SshKey.expects(:delete_from_authorized_keys).with('fofofo')
    options = {
      :target_class => 'SshKey',
      :command => 'delete_from_authorized_keys',
      :arguments => ['fofofo']
    }
    json = options.to_json
    @processor.on_message(json)
  end
end
