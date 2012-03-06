describe LabGroup do
  describe "relations" do
    it "should have a given course" do
      create(:lab_group).given_course.should_not be_nil
    end
  end

  describe "validations" do
    it "defaults to valid" do
      build(:lab_group).should be_valid
    end

    it "should not be possible to override identification number" do
      create(:lab_group, identification: nil).identification.should_not be_nil
    end

    it "should auto increment the identification number" do
      gc1 = create(:given_course)
      gc2 = create(:given_course)
      
      list1 = 3.times.map { create(:lab_group, given_course: gc1).identification }
      list2 = 3.times.map { create(:lab_group, given_course: gc2).identification }

      list1.uniq.count.should eq(3)
      list2.uniq.count.should eq(3)

      list2.should eq(list1)
    end
  end
end