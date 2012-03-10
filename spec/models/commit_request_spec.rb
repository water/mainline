describe CommitRequest do
  before (:each) do
    lab = create(:lab)
    student = create(:student)
    lab_group = create(:lab_group)
    create(:student_registered_for_course, lab_groups: [lab_group], student: student.user)
    repo = create(:lab_has_group, lab_group: lab_group, lab: lab).repository
    
    @value = {
      command: "move",
      user: student.user.id,
      repository: lab_group.lab_has_groups.first.repository.id,
      branch: "master",
      commit_message: "A commit message",
      files: [{
      from: "path/to/file.txt",
      to: "path/to/newfile.text"
      }]
    }
  end

  describe "validation" do 
    it "validates a commit request" do
      cr = CommitRequest.new(@value)
      cr.should be_valid
      cr.should_receive(:publish)
      cr.save
      cr.errors.should be_empty
    end

    describe "failing validations" do
      after (:each) do
        cr = CommitRequest.new(@value)
        cr.should_not be_valid
        cr.should_not_receive(:publish)
        cr.save
        cr.errors.should_not be_empty
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
        repo2 = build(:repository)
        @value[:repository] = repo2.id
      end 
    end
  end

  describe "commit_message generation" do
    it "should not generate a commit_message" do
      @value[:commit_message] = "CM"
      cr = CommitRequest.new(@value)
      cr.commit_message.should == "CM"
    end

    it "should generate a commit_message" do
      @value.delete :commit_message
      cr = CommitRequest.new(@value)
      cr.commit_message[0,10].should == "WebCommit:"
    end
  end
end
