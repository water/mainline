describe User do
  it "should respond to both examiner and assistent" do
    examiner = create(:examiner)
    given_course = create(:given_course, examiners: [examiner])
    user = examiner.user
    create(:assistant_registered_to_given_course, assistant: user, given_course: given_course)

    user.role_for_given_course?(:examiner, given_course).should be_true
    user.role_for_given_course?(:assistent, given_course).should be_true
    user.role_for_given_course?(:student, given_course).should be_false
  end
  
  it "should validate against a given course" do
    user = create(:user)
    given_course = create(:given_course)
    create(:student_registered_for_course, student: user, given_course: given_course)
    user.role_for_given_course?(:student, given_course).should be_true
  end

  it "can be an administrator" do
    admin = create(:administrator)
    admin.user.should be_admin
  end
end