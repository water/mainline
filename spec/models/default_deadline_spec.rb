describe DefaultDeadline do
  describe "validations" do
    it "should default to valid" do
      build(:default_deadline).should be_valid
    end

    it "should not be valid without a :at" do
      build(:default_deadline, at: nil).should_not be_valid
    end

    it "should not be valid without a :lab" do
      build(:default_deadline, lab: nil).should_not be_valid
    end

    it "should be valid without a description" do
      build(:default_deadline, description: nil).should be_valid
    end

    it "should not be have two similar deadlines" do
      lab1 = create(:lab)
      lab2 = create(:lab)
      create(:default_deadline, at: 3.days.from_now, lab: lab1)
      build(:default_deadline, at: 3.days.from_now + 1.minute, lab: lab1).should_not be_valid
      build(:default_deadline, at: 3.days.from_now + 1.minute, lab: lab2).should be_valid
    end
    
    it "should have a #at > current time" do
      build(:default_deadline, at: 3.days.ago).should_not be_valid
    end

    it "should validate #at with respect to DefaultDeadline::MINIMUM_TIME_DIFFERENCE" do
      lab = create(:active_lab)
      max_diff = DefaultDeadline::MINIMUM_TIME_DIFFERENCE

      at = 1.day.from_now + max_diff + 1.minute
      create(:default_deadline, {
        at: 1.day.from_now, 
        lab: lab
      })

      create(:default_deadline, {
        at: at, 
        lab: lab
      }).should be_valid

      build(:default_deadline, {
        at: at,
        lab: lab
      }).should_not be_valid
    end
  end

  describe "factories" do
    it "should be itselfs labs default deadline" do
      dd = create(:default_deadline)
      dd.lab.default_deadlines.should eq [dd]
    end

    it "should create only one default_deadline upon creation" do
      DatabaseCleaner.clean
      dd = create(:default_deadline)
      DefaultDeadline.count.should eq 1
    end

    it "can create many default deadlines" do
      default_deadline = create(:default_deadline)
      lab = default_deadline.lab
      create(:default_deadline, lab: lab)
      lab.should have(2).default_deadlines
    end
  end

  describe "ordering" do
    it "should order ascendingly" do
      DatabaseCleaner.clean
      DefaultDeadline.count.should be 0
      dd_3 = create(:default_deadline, at: 30.days.from_now)
      dd_1 = create(:default_deadline, at: 10.days.from_now)
      dd_2 = create(:default_deadline, at: 20.days.from_now)
      DefaultDeadline.count.should be 3
      DefaultDeadline.first.should eq dd_1
      DefaultDeadline.all.should eq [dd_1, dd_2, dd_3]
    end
  end

  describe "relations" do
    it "should have a lab" do
      create(:default_deadline).lab.should_not be_nil
    end
  end
end
