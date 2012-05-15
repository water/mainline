describe LabGroupsController do
  render_views
  describe "join" do
    it "should be member of group" do
      student = create(:student)
      gc = create(:given_course)
      lg = create(:lab_group, given_course: gc)
      src = create(:student_registered_for_course, 
      given_course: gc, student: student)

      login_as(student)
      post :join, role: "student", given_course: gc, 
        lab_group: {id: lg.id}
      lg.student_registered_for_courses << src
      lg.student_registered_for_courses.exists?(src).should be_true
    end
  end

  describe "POST /create" do
    student = FactoryGirl.create(:student)
    gc = FactoryGirl.create(:given_course)
    it "success notice is being shown" do
      login_as(student)
      post :create, role: "student", course_id: gc
      flash[:notice].should == "Lab Group was successfully created"
    end
  end

  describe "GET /new" do
    student = FactoryGirl.create(:student)
    gc = FactoryGirl.create(:given_course)
    it "should see a link to 'Create a Lab Group'" do
      login_as(student)
      visit new_course_lab_group_path("student", gc.id)
      page.should have_link('Create a Lab Group')
    end
  end

  describe "PUT /register" do
    it "should be possible to register for a lab" do
      gc = FactoryGirl.create(:given_course)
      lg = FactoryGirl.create(:lab_group, given_course: gc)
      lab = FactoryGirl.create(:lab, given_course: gc, active: true)
      put :register, id: lg.id, lab_id: lab.id
      LabHasGroup.find_by_lab_id_and_lab_group_id(lab.id, lg.id).lab_id.should eq(lab.id)
    end
  end
end
