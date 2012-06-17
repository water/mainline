# encoding: utf-8

require_relative "../test_helper"
require "ostruct"

class RepositoryTest < ActiveSupport::TestCase

  def new_repos(opts={})
    Repository.new({
      :name => "foo",
      :project => projects(:johans),
      :user => users(:johan),
      :owner => users(:johan)
    }.merge(opts))
  end

  def setup
    @repository = new_repos
    FileUtils.mkdir_p(@repository.full_repository_path, :mode => 0755)
  end

  subject { @repository }

  should_validate_presence_of :user_id, :name, :owner_id
  should_validate_uniqueness_of :hashed_path
  should_validate_uniqueness_of :name, :scoped_to => :project_id, :case_sensitive => false

  should_have_many :hooks, :dependent => :destroy

  should "inits the git repository" do
    path = @repository.full_repository_path
    Repository.git_backend.expects(:create).with(path).returns(true)
    Repository.create_git_repository(@repository.real_gitdir)

    assert File.exist?(path), 'File.exist?(path) should be true'

    Dir.chdir(path) do
      hooks = File.join(path, "hooks")
      assert File.exist?(hooks), 'File.exist?(hooks) should be true'
      assert File.symlink?(hooks), 'File.symlink?(hooks) should be true'
      assert File.symlink?(File.expand_path(File.readlink(hooks))), 'File.symlink?(File.expand_path(File.readlink(hooks))) should be true'
    end
  end

  should "clones a git repository" do
    source = repositories(:johans)
    target = @repository
    target_path = @repository.full_repository_path

    git_backend = mock("Git backend")
    Repository.expects(:git_backend).returns(git_backend)
    git_backend.expects(:clone).with(target.full_repository_path,
      source.full_repository_path).returns(true)
    Repository.expects(:create_hooks).returns(true)

    assert Repository.clone_git_repository(target.real_gitdir, source.real_gitdir)
  end

  should "not create hooks if the :skip_hooks option is set to true" do
    source = repositories(:johans)
    target = @repository
    target_path = @repository.full_repository_path

    git_backend = mock("Git backend")
    Repository.expects(:git_backend).returns(git_backend)
    git_backend.expects(:clone).with(target.full_repository_path,
      source.full_repository_path).returns(true)
    Repository.expects(:create_hooks).never

    Repository.clone_git_repository(target.real_gitdir, source.real_gitdir, :skip_hooks => true)
  end

  should " create the hooks" do
    hooks = "/path/to/hooks"
    path = "/path/to/repository"
    base_path = "#{Rails.root}/data/hooks"

    File.expects(:join).in_sequence.with(GitoriousConfig["repository_base_path"], ".hooks").returns(hooks)

    Dir.expects(:chdir).in_sequence.with(path).yields(nil)

    File.expects(:symlink?).in_sequence.with(hooks).returns(false)
    File.expects(:exist?).in_sequence.with(hooks).returns(false)
    FileUtils.expects(:ln_s).in_sequence.with(base_path, hooks)

    local_hooks = "/path/to/local/hooks"
    File.expects(:join).in_sequence.with(path, "hooks").returns(local_hooks)

    File.expects(:exist?).in_sequence.with(local_hooks).returns(true)

    File.expects(:join).with(path, "description").in_sequence

    File.expects(:open).in_sequence.returns(true)

    assert Repository.create_hooks(path)
  end

  should "deletes a repository" do
    Repository.git_backend.expects(:delete!).with(@repository.full_repository_path).returns(true)
    Repository.delete_git_repository(@repository.real_gitdir)
  end

  should "knows if has commits" do
    @repository.stubs(:new_record?).returns(false)
    @repository.stubs(:ready?).returns(true)
    git_mock = mock("Grit::Git")
    @repository.stubs(:git).returns(git_mock)
    head = mock("head")
    head.stubs(:name).returns("master")
    @repository.git.expects(:heads).returns([head])
    assert @repository.has_commits?, '@repository.has_commits? should be true'
  end

  should "knows if has commits, unless its a new record" do
    @repository.stubs(:new_record?).returns(false)
    assert !@repository.has_commits?, '@repository.has_commits? should be false'
  end

  should "knows if has commits, unless its not ready" do
    @repository.stubs(:ready?).returns(false)
    assert !@repository.has_commits?, '@repository.has_commits? should be false'
  end

  context "#to_xml" do
    should "xmlilizes git paths as well" do
      assert @repository.to_xml.include?("<clone-url>")
      assert @repository.to_xml.include?("<push-url>")
    end

    should "include a description of the kind" do
      assert_match(/<kind>mainline<\/kind>/, @repository.to_xml)
      @repository.kind = Repository::KIND_TEAM_REPO
      assert_match(/<kind>team<\/kind>/, @repository.to_xml)
    end

    should "include the project name" do
      assert_match(/<project>#{@repository.project.slug}<\/project>/, @repository.to_xml)
    end

    should "include the owner" do
      assert_match(/<owner kind="User">johan<\/owner>/, @repository.to_xml)
    end
  end

  should "publishes a message on create and update" do
    p = proc{
      @repository.save!
    }
    message = find_message_with_queue_and_regexp('/queue/GitoriousRepositoryCreation', /create_git_repository/) {p.call}
    assert_equal 'create_git_repository', message['command']
    assert_equal 1, message['arguments'].size
    assert_match(/#{@repository.real_gitdir}$/, message['arguments'].first)
    assert_equal @repository.id, message['target_id'].to_i
  end

  should "publishes a message on clone" do
    p = proc{
      @repository.parent = repositories(:johans)
      @repository.save!
    }
    message = find_message_with_queue_and_regexp('/queue/GitoriousRepositoryCreation', /clone_git_repository/) {p.call}
    assert_equal "clone_git_repository", message['command']
    assert_equal 2, message['arguments'].size
    assert_match(/#{@repository.real_gitdir}$/, message['arguments'].first)
    assert_equal @repository.id, message['target_id']
  end

  should "creates a notification on destroy" do
    @repository.save!
    message = find_message_with_queue_and_regexp(
      '/queue/GitoriousRepositoryDeletion',
      /delete_git_repository/) { @repository.destroy }
    assert_equal 'delete_git_repository', message['command']
    assert_equal 1, message['arguments'].size
    assert_match(/#{@repository.real_gitdir}$/, message['arguments'].first)
  end

  should "has one recent commit" do
    @repository.save!
    repos_mock = mock("Git mock")
    commit_mock = stub_everything("Git::Commit mock")
    repos_mock.expects(:commits).with("master", 1).returns([commit_mock])
    @repository.stubs(:git).returns(repos_mock)
    @repository.stubs(:has_commits?).returns(true)
    heads_stub = mock("head")
    heads_stub.stubs(:name).returns("master")
    @repository.stubs(:head_candidate).returns(heads_stub)
    assert_equal commit_mock, @repository.last_commit
  end

  should "has one recent commit within a given ref" do
    @repository.save!
    repos_mock = mock("Git mock")
    commit_mock = stub_everything("Git::Commit mock")
    repos_mock.expects(:commits).with("foo", 1).returns([commit_mock])
    @repository.stubs(:git).returns(repos_mock)
    @repository.stubs(:has_commits?).returns(true)
    @repository.expects(:head_candidate).never
    assert_equal commit_mock, @repository.last_commit("foo")
  end

  should "have a git method that accesses the repository" do
    # FIXME: meh for stubbing internals, need to refactor that part in Grit
    File.expects(:exist?).at_least(1).with("#{@repository.full_repository_path}/.git").returns(false)
    File.expects(:exist?).at_least(1).with(@repository.full_repository_path).returns(true)
    assert_instance_of Grit::Repo, @repository.git
    assert_equal @repository.full_repository_path, @repository.git.path
  end

  should "have a head_candidate" do
    head_stub = mock("head")
    head_stub.stubs(:name).returns("master")
    git = mock("git backend")
    @repository.stubs(:git).returns(git)
    git.expects(:head).returns(head_stub)
    @repository.expects(:has_commits?).returns(true)

    assert_equal head_stub, @repository.head_candidate
  end

  should "have a head_candidate, unless it doesn't have commits" do
    @repository.expects(:has_commits?).returns(false)
    assert_equal nil, @repository.head_candidate
  end

  should "has paginated_commits" do
    git = mock("git")
    commits = [mock("commit"), mock("commit")]
    @repository.expects(:git).times(2).returns(git)
    git.expects(:commit_count).returns(120)
    git.expects(:commits).with("foo", 30, 30).returns(commits)
    commits = @repository.paginated_commits("foo", 2, 30)
    assert_instance_of WillPaginate::Collection, commits
  end

  should "has a count_commits_from_last_week_by_user of 0 if no commits" do
    @repository.expects(:has_commits?).returns(false)
    assert_equal 0, @repository.count_commits_from_last_week_by_user(users(:johan))
  end

  should "returns a set of users from a list of commits" do
    commits = []
    users(:johan, :moe).map do |u|
      committer = OpenStruct.new(:email => u.email)
      commits << OpenStruct.new(:committer => committer, :author => committer)
    end
    users = @repository.users_by_commits(commits)
    assert_equal users(:johan, :moe).map(&:email).sort, users.keys.sort
    assert_equal users(:johan, :moe).map(&:login).sort, users.values.map(&:login).sort
  end

  should "sets a hash on create" do
    assert @repository.new_record?, '@repository.new_record? should be true'
    @repository.save!
    assert_not_nil @repository.hashed_path
    assert_equal 3, @repository.hashed_path.split("/").length
    assert_match(/[a-z0-9\/]{42}/, @repository.hashed_path)
  end

  should "know the full hashed path" do
    assert_equal @repository.hashed_path, @repository.full_hashed_path
  end

  context 'Logging updates' do
    setup {@repository = repositories(:johans)}

    should 'generate events for each value that is changed' do
      assert_incremented_by(@repository.events, :size, 1) do
        @repository.log_changes_with_user(users(:johan)) do
          @repository.replace_value(:name, "new_name")
        end
        assert @repository.save
      end
      assert_equal 'new_name', @repository.reload.name
    end

    should 'not generate events when blank values are provided' do
      assert_incremented_by(@repository.events, :size, 0) do
        @repository.log_changes_with_user(users(:johan)) do
          @repository.replace_value(:name, "")
        end
      end
    end

    should "allow blank updates if we say it's ok" do
      @repository.update_attribute(:description, "asdf")
      @repository.log_changes_with_user(users(:johan)) do
        @repository.replace_value(:description, "", true)
      end
      @repository.save!
      assert @repository.reload.description.blank?, "desc: #{@repository.description.inspect}"
    end

    should 'not generate events when invalid values are provided' do
      assert_incremented_by(@repository.events, :size, 0) do
        @repository.log_changes_with_user(users(:johan)) do
          @repository.replace_value(:name, "Some illegal value")
        end
      end
    end

    should 'not generate events when a value is unchanged' do
      assert_incremented_by(@repository.events, :size, 0) do
        @repository.log_changes_with_user(users(:johan)) do
          @repository.replace_value(:name, @repository.name)
        end
      end
    end
  end

  context "changing the HEAD" do
    setup do
      @grit = Grit::Repo.new(grit_test_repo("dot_git"), :is_bare => true)
      @repository.stubs(:git).returns(@grit)
    end

    should "change the head" do
      assert the_head = @grit.get_head("test/master")
      @grit.expects(:update_head).with(the_head).returns(true)
      @repository.head = the_head.name
    end

    should "not change the head if given a nonexistant ref" do
      @grit.expects(:update_head).never
      @repository.head = "non-existant"
      @repository.head = nil
      @repository.head = ""
    end

    should "change the head, even if the current head is nil" do
      assert the_head = @grit.get_head("test/master")
      @grit.expects(:head).returns(nil)
      @grit.expects(:update_head).with(the_head).returns(true)
      @repository.head = the_head.name
    end
  end

  context "garbage collection" do
    setup do
      @repository = repositories(:johans)
      @now = Time.now
      Time.stubs(:now).returns(@now)
      @repository.stubs(:git).returns(stub())
      @repository.git.expects(:gc_auto).returns(true)
    end
  end

  context "Fresh repositories" do
    setup do
      @me = FactoryGirl.create(:user, :login => "johnnie")
      @project = FactoryGirl.create(:project, :user => @me,
        :owner => @me)
      @repo = FactoryGirl.create(:repository, :project => @project,
        :owner => @project, :user => @me)
      @users = %w(bill steve jack nellie).map { | login |
        FactoryGirl.create(:user, :login => login)
      }
      @user_repos = @users.map do |u|
        new_repo = Repository.new_by_cloning(@repo)
        new_repo.name = "#{u.login}s-clone"
        new_repo.user = u
        new_repo.owner = u
        new_repo.kind = Repository::KIND_USER_REPO
        new_repo.last_pushed_at = 1.hour.ago
        assert new_repo.save
        new_repo
      end
    end

    should "include repositories recently pushed to" do
      assert @project.repositories.by_users.fresh(2).include?(@user_repos.first)
    end

    should "not include repositories last pushed to in the middle ages" do
      older_repo = @user_repos.pop
      older_repo.last_pushed_at = 500.years.ago
      older_repo.save
      assert !@project.repositories.by_users.fresh(2).include?(older_repo)
    end
  end

  context "Calculation of disk usage" do
    setup do
      @repository = repositories(:johans)
      @bytes = 90129
    end

    should "save the bytes used" do
      @repository.expects(:calculate_disk_usage).returns(@bytes)
      @repository.update_disk_usage
      assert_equal @bytes, @repository.disk_usage
    end
  end

end


