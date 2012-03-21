describe LabGroup do
  describe "relations" do
    let(:group) { create(:lab_group, students: [create(:student)]) }

    it "should have a given course" do
      group.given_course.should_not be_nil
    end

    it "should have a list of submissions" do
      lab = create(:lab, {given_course: group.given_course})
      lhg = create(:lab_has_group, {
        lab_group: group,
        lab: lab
      })

      2.times { create(:submission, {
        lab_has_group: lhg
      })}

      group.reload.should have(2).submissions
    end

    it "should have a list of students" do
      group.should have(1).students
    end

    it "should have a list of labs" do
      lab = create(:active_lab, given_course: group.given_course)
      create(:lab_has_group, lab: lab, lab_group: group)
      group.should have(1).labs
    end
  end

  describe "validations" do
    it "defaults to valid" do
      build(:lab_group).should be_valid
    end

    it "should not be possible to override number" do
      create(:lab_group, number: nil).number.should_not be_nil
    end

    it "should auto increment the number" do
      gc1 = create(:given_course)
      gc2 = create(:given_course)

      list1 = 3.times.map { create(:lab_group, given_course: gc1).number }
      list2 = 3.times.map { create(:lab_group, given_course: gc2).number }

      list1.uniq.count.should eq(3)
      list2.uniq.count.should eq(3)

      list2.should eq(list1)
    end
  end
end