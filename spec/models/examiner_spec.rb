describe Examiner do
  describe "validations" do
    it "should default to valid" do
      build(:examiner).should be_valid
    end

    it "should not be valid without a user" do
      build(:examiner, user: nil).should_not be_valid
    end
  end

  describe "relations" do
    it "should have a list of given courses" do
      create(:examiner, given_courses: [create(:given_course)]).should have(1).given_courses
    end

    it "should have a list of labs" do
      create(:examiner, labs: [create(:lab)]).should have(1).labs
    end
  end
end