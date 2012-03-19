describe User do
  it "should respond to both examiner and assistent" do
    examiner = create(:examiner)
    given_course = create(:given_course, examiners: [examiner])
    user = examiner.user
    assistant = create(:assistant, user: user)
    create(:assistant_registered_to_given_course, assistant: assistant, given_course: given_course)

    user.role_for_given_course?(:examiner, given_course).should be_true
    user.role_for_given_course?(:assistent, given_course).should be_true
    user.role_for_given_course?(:student, given_course).should be_false
  end
  
  it "should validate against a given course" do
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