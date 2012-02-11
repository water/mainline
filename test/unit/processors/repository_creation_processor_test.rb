# encoding: utf-8


require File.dirname(__FILE__) + '/../../test_helper'

class RepositoryCreationProcessorTest < ActiveSupport::TestCase

  def setup
    @processor = RepositoryCreationProcessor.new    
    @repository = repositories(:johans)
    
    @clone = mock
    @clone.stubs(:id).returns(99)
    @clone.stubs(:ready).returns(true)
    @clone.expects(:ready=).once.returns(true)
    @clone.expects(:save!).once
    Repository.stubs(:find_by_id).returns(@clone)
  end
  
  should "supplies two repos when cloning an existing repository" do
    Repository.expects(:clone_git_repository).with('foo', 'bar')
    options = {
      :target_class => 'Repository', 
      :target_id => @clone.id, 
      :command => 'clone_git_repository', 
      :arguments => ['foo', 'bar']}
    message = options.to_json
    @processor.on_message(message)
  end
  
 should "supplies one repo when creating a new repo" do
    Repository.expects(:create_git_repository).with('foo')
    options = {
      :target_class => 'Repository', 
      :target_id => @clone.id, 
      :command => 'create_git_repository', 
      :arguments => ['foo']}
    message = options.to_json
    @processor.on_message(message)
  end
  
end
