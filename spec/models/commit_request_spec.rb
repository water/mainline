
describe CommitRequest do
    def create_user_project_repo(repo_id,unique_name)
        user = Factory.build(:user)
        user.save
#        project = Project.new({
#          :title => unique_name,
#          :slug => unique_name,
#          :description => "my little project",
#          :user => user,
#          :owner => user
#        })
#        project.save
        repo = Repository.new({
            :name => unique_name,
            :user => user,
            :owner => user
#            :project => project
        })
        repo.id = repo_id
        repo.save
        [user,  repo]
    end
        let(:given_course) { create(:given_course)}
        let(:user) { create(:user)}
        let(:registered_course) { build(:registered_course)}
    before (:each) do
        @user,@repo = create_user_project_repo( 123, "foo")
        @user2,@repo2 = create_user_project_repo( 321, "bar")
        @value = {
            command: "move",
            user: @user.id,
            repository: 123,
            branch: "master",
            commit_message: "A commit message",
            files: [{
            from: "path/to/file.txt",
            to: "path/to/newfile.text"
            }]
        }
        @rc = create(:registered_course)
        @rc.student_id = @user.id
        @labgroup = create(:lab_group)
        @labgroup.registered_course_id = @rc.id
        @labgroup.save
        @ghu = GroupHasUser.new(:student_id => @user.id , :lab_group_id => @labgroup.id)
        @ghu.save!
        @lhg = LabHasGroup.new(:lab_group_id => @labgroup.id , :repo_id => @repo.id)
        @lhg.save!
    end

  describe "validation" do 
    it "validates a commitrequest" do
      @cr = CommitRequest.new(@value)
      @cr.should be_valid
      @cr.should_receive(:enqueue)
      @cr.save
      @cr.errors.should be_empty
    end

    describe "failing validations" do
        after (:each) do
          @cr = CommitRequest.new(@value)
          @cr.should_not be_valid 
          @cr.should_not_receive(:enqueue)
          @cr.save
          @cr.errors.should_not be_empty
        end
        it "should fail with an invalid command" do
          @value[:command] = "fiskpinne"
        end 
        it "should fail with an invalid user" do
          @value[:user] = 456 #random number
        end 
        it "should fail with an invalid repository" do
          @value[:repository] = 234 #random number
        end 
        it "should fail with another groups repository" do
          @value[:repository] = @repo2.id
        end 
    end
  end
  describe "commit_message generation" do
    it "should not generate a commit_message" do
        @value[:commit_message] = "CM"
        @cr = CommitRequest.new(@value)
        @cr.commit_message.should == "CM"
    end
    it "should generate a commit_message" do
        @value.delete :commit_message
        @cr = CommitRequest.new(@value)
        @cr.commit_message[0,10].should == "WebCommit:"
    end
  end
end
