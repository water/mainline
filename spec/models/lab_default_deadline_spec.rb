describe LabDefaultDeadline do
  it "should default to valid" do
    Factory.build(:lab_default_deadline).should be_valid
  end

  it "should not be valid without a :at" do
    Factory.build(:lab_default_deadline, at: nil).should_not be_valid
  end

  it "should not be valid without a :lab" do
    Factory.build(:lab_default_deadline, lab: nil).should_not be_valid
  end

  it "should be valid without a description" do
    Factory.build(:lab_default_deadline, description: nil).should be_valid
  end

  it "should not be have two similar deadlines" do
    lab1 = create(:lab)
    lab2 = create(:lab)
    create(:lab_default_deadline, at: 3.days.from_now, lab: lab1)
    build(:lab_default_deadline, at: 3.days.from_now + 1.minute, lab: lab1).should_not be_valid
    build(:lab_default_deadline, at: 3.days.from_now + 1.minute, lab: lab2).should be_valid
  end
end