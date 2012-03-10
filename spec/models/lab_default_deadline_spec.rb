describe LabDefaultDeadline do
  describe "validations" do
    it "should default to valid" do
      build(:lab_default_deadline).should be_valid
    end

    it "should not be valid without a :at" do
      build(:lab_default_deadline, at: nil).should_not be_valid
    end

    it "should not be valid without a :lab" do
      build(:lab_default_deadline, lab: nil).should_not be_valid
    end

    it "should be valid without a description" do
      build(:lab_default_deadline, description: nil).should be_valid
    end

    it "should not be have two similar deadlines" do
      lab1 = create(:lab)
      lab2 = create(:lab)
      create(:lab_default_deadline, at: 3.days.from_now, lab: lab1)
      build(:lab_default_deadline, at: 3.days.from_now + 1.minute, lab: lab1).should_not be_valid
      build(:lab_default_deadline, at: 3.days.from_now + 1.minute, lab: lab2).should be_valid
    end
  end

  describe "relations" do
    it "should have a lab" do
      create(:lab_default_deadline).lab.should_not be_nil
    end
  end
end