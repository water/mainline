describe Assistant do
  describe "relations" do
    it "should default to valid" do
      build(:assistant).should be_valid
    end

    it "should not be valid without a user" do
      build(:assistant, user: nil).should_not be_valid
    end

    it "should have a list of given courses" do
      create(:assistant).should have_at_least(1).given_courses
    end

    it "should have a list of lab groups" do
      create(:assistant).should have_at_least(1).lab_groups
    end

    it "should be able to list all lab groups" do
      create(:assistant).should have_at_least(1).all_lab_groups
    end

    it "should have a list of labs" do
      create(:assistant, labs: [create(:lab)]).should have(1).labs
    end

    it "should list submissions" do
      create(:assistant).should have(0).submissions
    end

    it "should list all submissions" do
      a = create(:assistant)
      lhg = create(:lab_has_group)
      s = create(:submission, lab_has_group: lhg)

      create(:assistant_registered_to_given_course, {
        assistant: a, 
        given_course: lhg.lab.given_course
      })
      a.should have(1).all_submissions
    end

    it "should have a list of students" do
      create(:assistant, students: [create(:student)]).should have(1).students
    end
  end

  describe "abilities" do
    before :all do
      @lhg = create(:lab_has_group)
      @a = create(:assistant)
      @submission = create(:submission, lab_has_group: @lhg)
      
      create(:assistant_registered_to_given_course, {
        assistant: @a, 
        given_course: @lhg.lab.given_course,
        lab_has_groups: [@lhg]
      })
      
      @ability = Ability.new(@a.user)
    end
    
    it "should be able to grade a valid lab" do
      @ability.should be_able_to(:review, @submission)
    end
    
    it "should not be able to grade an invalid lab" do
      lhg2 = create(:lab_has_group)
      submission2 = create(:submission, lab_has_group: lhg2)
      
      @ability.should_not be_able_to(:review, submission2)
    end
  end

  describe "dependent destroy" do
    it "should no be possible for a assistant_registered_to_given_course to exist without a assistant" do
      assis = FactoryGirl.create(:assistant)
      ar = FactoryGirl.create(:assistant_registered_to_given_course, assistant: assis)
      assis.destroy
      lambda{ar.reload}.should  raise_error(ActiveRecord::RecordNotFound)
    end
  end
end