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

    if "should not accept non-unique given_course, number tuples" do
      Factory.create(:lab, given_course: 1, lab_description: 1, )
    end
  end
end
