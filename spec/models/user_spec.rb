describe User do
  it "should respond to both examiner and assistent" do
    DatabaseCleaner.clean
    examiner = create(:examiner)
    given_course = create(:given_course, examiners: [examiner])
    user = examiner.user
    assistant = create(:assistant, user: user)
    create(:assistant_registered_to_given_course, assistant: assistant, given_course: given_course)

    user.role_for_given_course?(:examiner, given_course).should be_true
    user.role_for_given_course?(:student, given_course).should be_false
    user.role_for_given_course?(:assistant, given_course).should be_true
  end
  
  it "should validate against a given course" do
    DatabaseCleaner.clean
    student = create(:student)
    given_course = create(:given_course)
    create(:student_registered_for_course, student: student, given_course: given_course)
    student.user.role_for_given_course?(:student, given_course).should be_true
  end

  it "can be an administrator" do
    admin = create(:administrator)
    admin.user.should be_admin
  end
  
  describe "token" do
    it "should exist" do
      user = create(:user)
      user.token.should_not be_nil
    end
  
    it "should be valid" do
      user = create(:user)
      user.token.should match(/[a-f0-9]{40}/)
    end
    
    it "should be unique" do
      create(:user).token.should_not equal(create(:user).token)
    end
  end
  
  describe "dependent destroy" do
    it "should not be possible for a student to exist without a user" do
      user = FactoryGirl.create(:user)
      s = FactoryGirl.create(:student, user: user)
      user.destroy
      lambda{s.reload}.should raise_error(ActiveRecord::RecordNotFound)
    end

    it "should not be possible for a examiner to exist without a user" do
      user = FactoryGirl.create(:user)
      exa = FactoryGirl.create(:examiner, user: user)
      user.destroy
      lambda{exa.reload}.should raise_error(ActiveRecord::RecordNotFound)
    end

    it "should not be possible for a assistant to exist without a user" do
      user = FactoryGirl.create(:user)
      assistant = FactoryGirl.create(:assistant, user: user)
      user.destroy
      lambda{assistant.reload}.should raise_error(ActiveRecord::RecordNotFound)
    end

    it "should not be possible for a administrator to exist without a user" do
      user = FactoryGirl.create(:user)
      admin = FactoryGirl.create(:administrator, user: user)
      user.destroy
      lambda{admin.reload}.should raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "relations" do
    it "should have a student" do
      create(:student).user.student.should_not be_nil
    end

    it "should have a examiner" do
      create(:examiner).user.examiner.should_not be_nil
    end

    it "should have a administrator" do
      create(:administrator).user.administrator.should_not be_nil
    end

    it "should have a assistant" do
      create(:assistant).user.assistant.should_not be_nil
    end
  end
end