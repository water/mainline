describe DashboardsController do
  render_views
  
  describe "Shared behaviour" do
    before :all do
      @student = FactoryGirl.create(:student_registered_for_course).student
      @assistant = FactoryGirl.create(:assistant, user: @student.user)
      @group = FactoryGirl.create(:lab_group, given_course: @student.given_courses.first)
      @lab = FactoryGirl.create(:lab, given_course: @student.given_courses.first)
      @group.add_student(@student)
      @lab.add_group!(@group)
      @student.given_courses.first.register_assistant(@assistant)
      @course2 = FactoryGirl.create(:given_course)
      @course2.register_student(@student)
    end
  
    describe "Student dashboard" do
      
      before :each do 
        login_as(@student)
        visit dashboard_path(role: "student")
      end
    
      it "shows a particular course" do
        page.should have_content(@lab.given_course.course.course_codes.first.code)
      end
    
      it "shows two courses" do
        page.should have_content(@lab.given_course.course.course_codes.first.code)
        page.should have_content(@course2.course.course_codes.first.code)
      end
    
      it "shows a lab" do
        page.should have_content(@lab.numbered_name)
      end
    end
  
    describe "Assistant dashboard" do
      before :each do 
        login_as(@assistant)
        visit dashboard_path(role: "assistant")
      end
      
      it "shows a particular course" do
        page.should have_content(@lab.given_course.course.course_codes.first.code)
      end
    
      it "shows two courses" do
        page.should have_content(@lab.given_course.course.course_codes.first.code)
        page.should have_content(@course2.course.course_codes.first.code)
      end
    
      it "shows a lab" do
        page.should have_content(@lab.numbered_name)
      end
    end
  end
end