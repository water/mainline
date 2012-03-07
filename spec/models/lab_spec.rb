describe Lab do
  describe 'validation' do
    it "defaults to valid" do
      Factory.build(:lab).should be_valid
    end

    it "should not be valid without a lab_description" do
      Factory.build(:lab, lab_description: nil).should_not be_valid
    end

    it "should not be valid without a given_course" do
      Factory.build(:lab, given_course: nil).should_not be_valid
    end

    it "should not be possible to set force an invalid #number" do
      Factory.build(:lab, number: nil).should be_valid
      Factory.build(:lab, number: "fail").should be_valid
    end

    it "increments #number with respect to a given course" do
      g1 = create(:given_course)
      g2 = create(:given_course)
      
      r1 = 3.times.map { create(:lab, given_course: g1).number }
      r2 = 3.times.map { create(:lab, given_course: g2).number }

      r1.uniq.count.should eq(3)
      r2.uniq.count.should eq(3)

      r1.should eq(r2)
    end

    it "should not accept non-unique given_course, number tuples" do
      lab = Factory.create(:lab)
      Factory.build(:lab, {
        given_course: lab.given_course, 
        lab_description: lab.lab_description
      }).should_not be_valid
    end
  end
end
