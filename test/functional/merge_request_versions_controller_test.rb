# encoding: utf-8


require_relative "../test_helper"

class MergeRequestVersionsControllerTest < ActionController::TestCase

  should_render_in_site_specific_context

  context 'Viewing diffs' do
    setup do
      @merge_request = merge_requests(:moes_to_johans)
      @merge_request.stubs(:calculate_merge_base).returns("ffac0")
      @version = @merge_request.create_new_version
      @git = mock

      #(repo, id, parents, tree, author, authored_date, committer, committed_date, message)
      @commit = Grit::Commit.new(mock("repo"), "mycommitid", [], stub_everything("tree"),
        stub_everything("author"), Time.now, stub_everything("comitter"), Time.now,
        "my commit message".split(" "))

      Repository.any_instance.stubs(:git).returns(@git)
      MergeRequestVersion.stubs(:find).returns(@version)

      # Solely to match routes - the controller doesn't actually use this to scope.
      @project = projects(:johans)
      @repository = repositories(:johans)
      @merge_request = merge_requests(:moes_to_johans)
    end
    
    context 'Viewing the diff for a single commit' do
      setup do
        @version.expects(:diffs).with("ffcab").returns([])
        @git.expects(:commit).with("ffcab").returns(@commit)
        get :show, :id => @version.to_param, :commit_shas => "ffcab", :project_id => @project.to_param, :repository_id => @repository.to_param, :merge_request_id => @merge_request.to_param, :format => "js"
      end      
      should_respond_with :success
      should_assign_to(:commit, :class => Grit::Commit){ @commit }
    end
    
    context 'Viewing the diff for a series of commits' do
      setup do
        @version.expects(:diffs).with("ffcab".."bacff").returns([])
        get :show, :id => @version.to_param, :commit_shas => "ffcab-bacff", :project_id => @project.to_param, :repository_id => @repository.to_param, :merge_request_id => @merge_request.to_param, :format => "js"
      end
      should_respond_with :success
      should_not_assign_to(:commit)
    end
    
    context 'Viewing the entire diff' do
      setup do
        @version.expects(:diffs).returns([])
        get :show,  :id => @version.to_param, :project_id => @project.to_param, :repository_id => @repository.to_param, :merge_request_id => @merge_request.to_param, :format => "js"
      end
      should_respond_with :success
    end
  end
end
