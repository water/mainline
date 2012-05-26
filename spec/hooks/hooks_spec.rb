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

  end
end



