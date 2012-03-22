describe CommitRequest do
  before (:each) do
    lab = create(:lab)
    student = create(:student)
    lab_group = create(:lab_group, given_course: lab.given_course)
    create(:student_registered_for_course, lab_groups: [lab_group], student: student)
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

      it "should fail with an invalid filename" do
           @value[:command] = "add"
           @value[:files] = [
            {id: 123, to: "src/main\0.cpp"},
            {id: 124, to: "src/lib<hej>.h"},
            {id: 125, to: "src/lib|?.cpp"}
           ]
      end

      it "should fail with an invalid command" do
        @value[:command] = "fiskpinne"
      end

      it "should fail with an invalid branch" do
        @value[:branch] = "fiskpinne"
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

    it "should send message to front end using faye" do
      faye = mock(Object.new)
      config = APP_CONFIG["faye"]
      SecureFaye::Connect.
        should_receive(:new).
        and_return(faye)

      faye.should_receive(:message).
        with({status: 200}.to_json).
        and_return(faye)

      faye.should_receive(:token).
        with(config["token"]).
        and_return(faye)

      faye.should_receive(:server).
        with("http://0.0.0.0:#{config["port"]}/faye").
        and_return(faye)

      faye.should_receive(:channel).
        with("/users/#{@value["token"]}").
        and_return(faye)

      faye.should_receive(:send!)

      CommitRequest.notify_user(@value.stringify_keys!)
    end

    it "should be able to generate proper error messages" do
      cr = CommitRequest.new(@value.merge(user: nil))
      cr.save
      cr.errors.should_not be_empty
    end
  end

  describe "commit_message generation" do
    it "should overwrite the commit_message for being to short" do
      @value[:commit_message] = "CM"
      cr = CommitRequest.new(@value)
      cr.commit_message[0,10].should == "WebCommit:"
    end

    it "should overwrite the commit_message for being to long" do
      @value[:commit_message] = "This is a long commit_message,
      in fact it is to long for the commit_request model to validate.
      This will cause the model to overwrite it with a default commitmessage"
      cr = CommitRequest.new(@value)
      cr.commit_message[0,10].should == "WebCommit:"
    end

    it "should not generate a commit_message" do
      @value[:commit_message] = "A Commit Message"
      cr = CommitRequest.new(@value)
      cr.commit_message.should == "A Commit Message"
    end

    it "should generate a commit_message" do
      @value.delete :commit_message
      cr = CommitRequest.new(@value)
      cr.commit_message[0,10].should == "WebCommit:"
    end
  end
end
