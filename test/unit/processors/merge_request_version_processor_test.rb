# encoding: utf-8


require File.dirname(__FILE__) + '/../../test_helper'

class MergeRequestVersionProcessorTest < ActiveSupport::TestCase
  
  def setup
    @processor = MergeRequestVersionProcessor.new
    @version = merge_request_versions(:first_version_of_johans_to_mikes)
    @merge_request = @version.merge_request
    @tracking_repository = @merge_request.tracking_repository
    @source_repository = @merge_request.source_repository
    @message = @version.branch_deletion_message
  end
  
  def teardown
    @processor = nil
  end

  context "Deletion of merge request tracking branches" do
    setup {
      @processor.parse(@message.to_json)
    }
    
    should "push an empty tag to the target repository" do
      repo = mock
      repo.expects(:push).with(
        {:timeout => false},
        @tracking_repository.full_repository_path,
        ":#{@merge_request.merge_branch_name(@version.version)}"
        )
      @source_repository.expects(:git).returns(mock(:git => repo))
      @processor.stubs(:source_repository).returns(@source_repository)
      @processor.delete_branch
    end
  end

  context "Missing git repository" do
    setup { @processor.parse(@message.to_json) }
    
    should "log an appropriate message when source repository is missing" do
      @processor.expects(:log_error)
      @processor.delete_branch
    end
  end

  context "Internals" do
    setup {
      @processor.parse(@message.to_json)
    }

    should "extract the correct source repository path" do
      assert_equal(@source_repository.full_repository_path,
        @processor.source_repository_path)
    end

    should "extract the correct tracking repository path" do
      assert_equal(@tracking_repository.full_repository_path,
        @processor.tracking_repository_path)
    end

    should "extract the branch name" do
      assert_equal(@merge_request.merge_branch_name(@version.version),
        @processor.target_branch_name)
    end

    should "find the source repository" do
      assert_equal @source_repository, @processor.source_repository
    end
  end
end
