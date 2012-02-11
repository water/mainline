# encoding: utf-8


require File.dirname(__FILE__) + '/../../test_helper'

class MergeRequestProcessorTest < ActiveSupport::TestCase

  def setup
    @processor = MergeRequestProcessor.new
    @merge_request = merge_requests(:moes_to_johans_open)
    @target_repo = @merge_request.target_repository
    @merge_request.stubs(:target_repository).returns(@target_repo)
    MergeRequest.expects(:find).with(@merge_request.id).returns(@merge_request)
    @tracking_repo = mock("Tracking repository")
    @tracking_repo.stubs(:real_gitdir).returns("ff0/bbc/234")
    @target_repo.stubs(:create_tracking_repository).returns(@tracking_repo)
  end

  should 'send a repo creation message when the target repo does not have a MR repo' do
    message = {'merge_request_id' => @merge_request.id}.to_json
    @target_repo.expects(:has_tracking_repository?).once.returns(false)
    Repository.expects(:clone_git_repository).with(
      @tracking_repo.real_gitdir,
      @merge_request.target_repository.real_gitdir, :skip_hooks => true).once
    @merge_request.expects(:'push_to_tracking_repository!').with(true).once
    @processor.on_message(message)
  end

  should 'create a new branch from the merge request' do
    message = {'merge_request_id' => @merge_request.id}.to_json
    @target_repo.expects(:'has_tracking_repository?').once.returns(true)
    @processor.expects(:create_tracking_repository).never
    @merge_request.expects(:'push_to_tracking_repository!').once
    @processor.on_message(message)
  end
end
