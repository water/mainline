require './vendor/grack/lib/git_http.rb'
require './lib/grack/water_grack_auth.rb'

describe "WaterGrackAuth" do
  include Rack::Test::Methods

  def app
    config = {
      :project_root => "/tmp",
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

  let(:lab_has_group) { create(:lab_has_group) }
  let(:repo) { lab_has_group.repository }
  let(:lab) { lab_has_group.lab }
  let(:lab_group) { lab_has_group.lab_group }
  let(:student) { create(:student) }
  let(:user) { student.user }
  let(:given_course) { lab_group.given_course }
  let(:url) { %W{http://localhost:9292/
                 courses/#{given_course.id}/
                 labs/#{lab.number}.git
    }.join "" # TODO: Why localhost part??
  }

  before(:each) do
    given_course.register_student(student)
    lab_group.add_student(student)
  end

  describe "authentication" do
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
    it "can clone a repo" do
      true.should be_false
    end
  end

  describe "course with many students" do
    it "allows collaboration in same group" do
      true.should be_false
    end

    it "gives students in different groups different repos" do
      true.should_be false
    end
  end
end

