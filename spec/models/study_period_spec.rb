describe StudyPeriod do
  describe "validation" do
    it "requires a proper year" do
      build(:study_period, year: 2001).should be_valid
      build(:study_period, year: 1).should_not be_valid
    end
    
    it "requires a study period > 0" do
      build(:study_period, period: 0).should_not be_valid
      build(:study_period, period: 1).should be_valid
    end
  end
end
