describe "Git hooks" do

  let(:lab_has_group) { create(:lab_has_group, repository: repository) }
  let(:lab) { lab_has_group.lab }
  let(:lab_group) { lab_has_group.lab_group }
  let(:student) { create(:student) }
  let(:user) { student.user }
  let(:given_course) { lab_group.given_course }
  let(:url) { repository.full_repository_path }
  let(:repository) { create(:repo_with_data) }

  before(:each) do
    given_course.register_student(student)
    lab_group.add_student(student)
    Dir.chdir(Dir.mktmpdir)
    `git clone #{url} dir`
    Dir.chdir "dir"
  end

  def mutate_and_add!
    `echo a >> a && git add a`
  end

  def push(branch)
    `git push origin #{branch}`
  end

  it "can submit a repo" do
    p url
    p Dir.pwd
    mutate_and_add!
    `git commit -m 'I want to #submit'"`
    Submission.first.should be_nil
    push "master"
    Submission.first.should_not be_nil
  end

end



