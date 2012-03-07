describe Course do
  describe "validation" do
    it "should have at least one course code" do
      Factory.build(:course).should_not be_valid
      Factory.build(:course_with_course_code).should be_valid
    end
  end

  describe "relations" do
    it "should not be valid" do
      Factory.build(:course_without_department).should_not be_valid
    end

    it "should have a department" do
      att = Factory.attributes_for(:course_without_department)
      2.times {
        Course.create({
          department_attributes: { name: "IT" }
        }.merge(att)).should_not be_nil
      }

      Department.all.count.should eq(1)
    end
  end
end
