describe Course do
  describe "validation" do
    it "should have at least one course code" do
      Factory.build(:course).should_not be_valid
      Factory.create(:course_with_course_code).should_not be_nil
    end
  end

  describe "relations" do
    it "should not be valid" do
      Factory.build(:course_without_department).should_not be_valid
    end

    it "should have a department" do
      att = Factory.attributes_for(:course_without_department)
      Course.create!({
        department_attributes: { name: "IT" }
      }.merge(att)).should_not be_nil

      Department.find_by_name("IT").should_not be_nil
    end

    it "should have a list of course codes" do
      Course.create!({
        course_codes_attributes: [{ code: "TDA123" }],
        department_attributes: { name: "IT" }
      }).should_not be_nil

      CourseCode.find_by_code("TDA123").should_not be_nil
    end
  end
end
