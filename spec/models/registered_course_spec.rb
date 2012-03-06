describe RegisteredCourse do
  let(:given_course) { create(:given_course) }
  let(:user) { create(:user) }
  let(:registered_course) { build(:registered_course) }
  
  describe "validation" do
    
    it "should only contain one unique pair" do
      create(:registered_course, student: user, given_course: given_course).should be_valid
      build(:registered_course, student: user, given_course: given_course).should_not be_valid
    end

    it "should be valid" do
      build(:registered_course).should be_valid
    end
    
    it "requires a student" do
      build(:registered_course, student: nil).should_not be_valid
    end
    
    it "requires a given course" do
      build(:registered_course, given_course: nil).should_not be_valid
    end
  end
  
  describe "relation" do
    it "should have a lab group" do
      lab_group = create(:lab_group)
      registered_course.lab_groups << lab_group
      registered_course.should have_at_least(1).lab_groups
    end
  end
end