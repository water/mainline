describe Course do
  describe "validation" do
    it "should have at least one course code" do
      Factory.build(:course).should_not be_valid
      Factory.build(:course_with_course_code).should be_valid
    end
  end
end
