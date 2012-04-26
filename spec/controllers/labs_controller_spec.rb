describe LabsController do
  render_views
  describe "POST join" do
    it "should test join action" do
      student = FactoryGirl.create(:student)
      course = FactoryGirl.create(:given_course)
      group = FactoryGirl.create(:lab_group, given_course: course)
      lab = FactoryGirl.create(:lab, given_course: course, active: true)
      login_as(student)
      post :join, lab_group_id: group.id, lab_id: lab.id
      response.status.should eq(302)
    end
  end
  
  describe "GET /show" do
    describe "student" do
      let(:student) { FactoryGirl.create(:student) }
      
      before :all do 
        @given_course = Factory.create(:given_course)
        @srfc = Factory.create(:student_registered_for_course, {
      it "has breadcrumbs" do
        given_course = FactoryGirl.create(:given_course)
        srfc = FactoryGirl.create(:student_registered_for_course, {
          student: student,
          given_course: given_course
        })

        @lab = Factory.create(:active_lab, given_course: @given_course)
        @group = Factory.create(:lab_group, given_course: @given_course)

        Factory.create(:lab_has_group, {
          lab: @lab,
          lab_group: @group, 
          grade: nil
        })

        login_as(student)
      end
      
      it "doesn't crash" do
        visit course_lab_group_lab_path("student", @given_course, @group, @lab)
        page.status_code.should eq(200)
      end
      
      it "has breadcrumbs" do
        visit course_lab_group_lab_path("student", @given_course, @group, @lab)
        page.should have_selector('div.breadcrumbs')
      end
      
      it "gives an error if the lab group doesn't exist in the course" do
        given_course2 = Factory.create(:given_course)
        visit course_lab_group_lab_path("student", given_course2, @group, @lab)  
        page.status_code.should eq(404)
      end
    end
  end

  describe "GET /labs" do
    describe "student" do
      let(:student) { FactoryGirl.create(:student) }
      
      it "should return all non finished labs" do
        login_as(student)
        given_course = FactoryGirl.create(:given_course)
        srfc = FactoryGirl.create(:student_registered_for_course, {
          student: student,
          given_course: given_course
        })

        lab_group = FactoryGirl.create(:lab_group, given_course: given_course)
        labs = []

        # Active lab
        labs << FactoryGirl.create(:lab, {
          lab_description: FactoryGirl.create(:lab_description, title: "Lab 1"),
          active: true,
          given_course: given_course
        })

        # Non acitve lab
        labs << FactoryGirl.create(:lab, {
          lab_description: FactoryGirl.create(:lab_description, title: "Lab 2"),
          active: false,
          given_course: given_course
        })

        # Non related lab
        FactoryGirl.create(:lab, {
          lab_description: FactoryGirl.create(:lab_description, title: "Lab 3"),
          active: true,
          given_course: given_course
        })

        srfc.lab_groups << lab_group

        labs.each do |lab|
          FactoryGirl.create(:lab_has_group, {
            lab: lab,
            lab_group: lab_group
          })
        end

        visit labs_path({role: "student"})

        page.should have_content("Lab 1")
        page.should_not have_content("Lab 2")
        page.should_not have_content("Lab 3")
        page.should have_content(labs.first.description)
      end
    end

    describe "examiner" do
      let(:examiner) { FactoryGirl.create(:examiner) }

      it "should return all non finished labs" do
        login_as(examiner)

        given_course = create(:given_course, examiners: [examiner])
        group = create(:lab_group, {
          given_course: given_course
        })

        labs = []

        # Active lab
        labs << FactoryGirl.create(:lab, {
          lab_description: FactoryGirl.create(:lab_description, title: "Lab 1"),
          active: true,
          given_course: given_course
        })

        # Non acitve lab
        labs << FactoryGirl.create(:lab, {
          lab_description: FactoryGirl.create(:lab_description, title: "Lab 2"),
          active: false,
          given_course: given_course
        })

        labs.each do |lab|
          FactoryGirl.create(:lab_has_group, {
            lab: lab,
            lab_group: group, 
            grade: nil
          })
        end

        visit labs_path({role: "examiner"})

        page.should have_content("Lab 1")
        page.should_not have_content("Lab 2")
        page.should have_content(labs.first.description)
      end
    end

    describe "assistant" do
      let(:assistant) { FactoryGirl.create(:assistant) }

      it "should return all non finished labs" do
        login_as(assistant)

        given_course = create(:given_course, assistants: [assistant])
        labs = []
        group = create(:lab_group, {
          given_course: given_course
        })

        # Active lab
        labs << FactoryGirl.create(:lab, {
          lab_description: FactoryGirl.create(:lab_description, title: "Lab 1"),
          active: true,
          given_course: given_course
        })

        # Non acitve lab
        labs << FactoryGirl.create(:lab, {
          lab_description: FactoryGirl.create(:lab_description, title: "Lab 2"),
          active: false,
          given_course: given_course
        })

        labs.each do |lab|
          FactoryGirl.create(:lab_has_group, {
            lab: lab,
            lab_group: group,
            grade: nil
          })
        end

        visit labs_path({role: "assistant"})

        page.should have_content("Lab 1")
        page.should_not have_content("Lab 2")
        page.should have_content(labs.first.description)
      end
    end

    describe "administrator" do
      let(:admin) { FactoryGirl.create(:administrator) }

      it "should return all non finished labs" do
        login_as(admin)
        labs = []
        gc = create(:given_course)
        group = create(:lab_group, {
          given_course: gc
        })

        # Active lab
        labs << FactoryGirl.create(:lab, {
          lab_description: FactoryGirl.create(:lab_description, title: "Lab 1"),
          active: true,
          given_course: gc
        })

        # Non acitve lab
        labs << FactoryGirl.create(:lab, {
          lab_description: FactoryGirl.create(:lab_description, title: "Lab 2"),
          active: false,
          given_course: gc
        })

        labs.each do |lab|
          FactoryGirl.create(:lab_has_group, {
            lab: lab,
            lab_group: group,
            grade: nil
          })
        end

        visit labs_path({role: "administrator"})

        page.should have_content("Lab 1")
        page.should have_content("Lab 2")
      end
    end

    describe "unknown" do
      it "should not be authorized when not logged in" do
        visit labs_path({role: "administrator"})
        current_path.should eq("/sessions/new")
      end
    end
  end
end
