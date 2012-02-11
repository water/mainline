# encoding: utf-8

require_relative "../test_helper"
require "fileutils"

class SshKeyFileTest < ActiveSupport::TestCase
  
  def fixture_key_path
    File.join(fixture_path, "authorized_keys_fixture")
  end
  
  def setup
    FileUtils.cp(File.join(fixture_path, "authorized_keys"), fixture_key_path)    
    @keyfile = SshKeyFile.new(fixture_key_path)
    @keydata = ssh_keys(:johan).to_ssh_key
  end
  
  def teardown
    FileUtils.rm(fixture_key_path) if File.exist?(fixture_key_path)
  end

  should "initializes with the path to the key file" do
    keyfile = SshKeyFile.new("foo/bar")
    assert_equal "foo/bar", keyfile.path
  end
  
  should "defaults to $HOME/.ssh/authorized_keys" do
    keyfile = SshKeyFile.new
    assert_equal File.join(File.expand_path("~"), ".ssh", "authorized_keys"), keyfile.path
  end
  
  should "reads all the data in the file" do
    assert_equal File.read(fixture_key_path), @keyfile.contents
  end
  
  should "adds a key to the authorized_keys file" do
    @keyfile.add_key(@keydata)
    assert @keyfile.contents.include?(@keydata)
  end
  
  should "deletes a key from the file" do
    @keyfile.add_key(@keydata)
    @keyfile.delete_key(@keydata)
    assert !@keyfile.contents.include?(@keydata)
    assert_equal File.read(File.join(fixture_path, "authorized_keys")), @keyfile.contents
  end
  
  should "doesn't rewrite the file unless the key to delete is in there" do
    File.expects(:open).never
    @keyfile.delete_key(@keydata)
  end

end
