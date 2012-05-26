describe "Git hooks" do

  let(:lab_has_group) { create(:lab_has_group, repository: repository) }
  let(:lab) { lab_has_group.lab }
  let(:lab_group) { lab_has_group.lab_group }
  let(:student) { create(:student) }
  let(:user) { student.user }
  let(:given_course) { lab_group.given_course }
  let(:url) { URI::HTTP.build(lab_has_group.uri_build_components.merge(
    userinfo: "#{user.login}:#{user.password}"
    ))
  }
  let(:repository) { create(:repo_with_data) }

  def mutate_and_add!
    `echo a >> a && git add a`
  end

  def commit(message)
    `git commit -m '#{message}'`
    `git rev-parse HEAD`.strip
  end

  def new_commit(message)
    mutate_and_add!
    commit(message)
  end

  def push(branch)
    `git push origin #{branch}`
  end

  def push_new_commit(message)
    hash = new_commit(message)
    push "master"
    hash
  end

  def submissions
    Submission.count
  end

  it "exists in server side repository" do
    Dir.exists?(File.join(repository.full_repository_path, "hooks")).should be_true
  end

  describe "Hooks" do

    before(:each) do
      Submission.delete_all
      given_course.register_student(student)
      lab_group.add_student(student)
      Dir.chdir(Dir.mktmpdir)
      `git clone #{url} dir`
      Dir.chdir "dir"
    end

    it "can submit a repo" do
      submissions.should eq 0
      new_commit "Do a #submit please"
      push "master"
      submissions.should eq 1
    end

    it "doesn't submit without #submit" do
      new_commit "Don't submit!"
      push "master"
      submissions.should eq 0
    end

    it "doesn't submit when not pushing to master" do
      `git checkout -b new_branch`
      new_commit "I wanna #submit but can't from this branch!"
      push "new_branch"
      submissions.should eq 0
    end

    it "doesn't resubmit unless it already has a submit" do
      push_new_commit "It's to early for #resubmit syntax"
      submissions.should eq 0
    end

    it "disallows to submit twice" do
      hash_orig = push_new_commit "Let's #submit"
      Submission.first.commit_hash.should eq hash_orig

      push_new_commit "Let's #submit again"
      Submission.first.commit_hash.should eq hash_orig
      submissions.should eq 1
    end

    it "allows resubmit" do
      push_new_commit "Let's #submit"
      new_hash = push_new_commit "Let's #resubmit"
      Submission.first.commit_hash.should eq new_hash
      submissions.should eq 1
    end

    it "puts's lab has group in pending" do
      lab_has_group.should be_initialized
      push_new_commit "#submit"
      lab_has_group.should be_pending
    end

    it "allows a second submission after rejection" do
      push_new_commit "#submit"
      lab_has_group.rejected!
      push_new_commit "#submit"
      submissions.should eq 2
    end

    it "doesn't allow submissions when it's accepted" do
      push_new_commit "#submit"
      lab_has_group.accepted!
      push_new_commit "#submit"
      submissions.should eq 1
    end

    it "doesn't allow resubmit when status is pending" do
      push_new_commit "#submit"
      lab_has_group.pending!
      push_new_commit "#resubmit"
      submissions.should eq 1
    end

    it "blocks submissions past deadline" do
      # TODO how to implement this test?
      true.should be_false
    end
  end
end



