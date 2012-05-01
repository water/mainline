require './vendor/grack/lib/git_http.rb'
require './lib/grack/water_grack_auth.rb'

describe "WaterGrackAuth" do
  include Rack::Test::Methods

  def auth(user)
    authorize user.login, user.password
  end

  def app
    config = {
      :project_root => "/tmp/git-repos",
      :upload_pack => true,
      :receive_pack => true,
    }
    Rack::Builder.new {
      use WaterGrackAuth
      run GitHttp::App.new(config)
    }
  end

  def r
    last_response
  end

  let(:lab_has_group) { create(:lab_has_group, repository: repository) }
  let(:lab) { lab_has_group.lab }
  let(:lab_group) { lab_has_group.lab_group }
  let(:student) { create(:student) }
  let(:user) { student.user }
  let(:given_course) { lab_group.given_course }
  let(:url) { %W{courses/#{given_course.id}/
                 labs/#{lab.number}/.git
    }.join ""
  }

  before(:each) do
    given_course.register_student(student)
    lab_group.add_student(student)
  end

  describe "authentication" do
    let(:repository) { create(:repository) }
    it "requires authentication" do
      get url
      r.status.should == 401
    end

    it "dismisses incorrect credentials" do
      authorize "fake_name", "fake_pw"
      get url
      r.status.should == 401
    end

    it "accepts correct credentials" do 
      authorize user.login, user.password
      get url
      r.status.should_not == 401
    end

    it "checks privileges of single user" do 
      user = create(:user)
      authorize user.login, user.password
      get url
      r.status.should == 401
    end

  end

  describe "git operations" do
    let(:repository) { create(:repo_with_data) }
    it "can clone a repo" do
      # true.should be_false
    end
  end

  describe "course with many students" do
    let(:repository) { create(:repo_with_data) }
    let(:student_2) { create(:student) }

    before(:each) do
      given_course.register_student(student_2)
    end

    def head_for(user)
      auth user
      get "#{url}/HEAD"
      r.body
    end

    it "allows collaboration in same group" do
      lab_group.add_student(student_2)
      head_for(user).should =~ /master/
      head_for(student_2.user).should =~ /master/

      Dir.chdir(repository.full_repository_path) do
        `echo "ref: refs/heads/my_branch" > HEAD`
      end
      head_for(user).should =~ /my_branch/
      head_for(student_2.user).should =~ /my_branch/
    end

    it "gives students in different groups different repos" do
      repository_2 = create(:repo_with_data) 
      lab_has_group_2 = create(:lab_has_group, { repository: repository_2, lab: lab }) 
      lab_group_2 = lab_has_group_2.lab_group
      lab_group_2.add_student(student_2)
      Dir.chdir(repository.full_repository_path) do
        `echo "ref: refs/heads/my_branch" > HEAD`
      end
      head_for(user).should =~ /my_branch/
      head_for(student_2.user).should =~ /master/
    end
  end
end

