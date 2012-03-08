describe CourseCode do
  describe "validations" do
    it "defaults to valid" do
      build(:course_code).should be_valid
    end

    it "should force uniqueness of code" do
      course_code = create(:course_code)
      build(:course_code, code: course_code.code).should_not be_valid
    end
  end

  describe "validations" do
    it "should have a course" do
      course = create(:course_with_course_code)
      cc = create(:course_code, course: course)
      cc.course.should eq(course)
    end
  end
end