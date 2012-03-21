describe LabsController do
  render_views
  describe "POST join" do
    it "should test join action" do
      student = Factory.create(:student)
      group = Factory.create(:lab_group)
      lab = Factory.create(:lab)
      labhasgroup = Factory.create(:lab_has_group)
      post :join, lab_group: group.id, lab_id: lab.id
    end
  end

  describe "GET /labs" do
    describe "student" do
      let(:student) { Factory.create(:student) }

      it "should return all non finished labs" do
        login_as(student)
        
        given_course = Factory.create(:given_course)

        srfc = Factory.create(:student_registered_for_course, {
          student: student,
          given_course: given_course
        })

        lab_group = Factory.create(:lab_group, given_course: given_course)
        labs = []

        # Active lab
        labs << Factory.create(:lab, {
          lab_description: Factory.create(:lab_description, title: "Lab 1"),
          active: true,
          given_course: given_course
        })

        # Non acitve lab
        labs << Factory.create(:lab, {
          lab_description: Factory.create(:lab_description, title: "Lab 2"),
          active: false,
          given_course: given_course
        })

        # Non related lab
        Factory.create(:lab, {
          lab_description: Factory.create(:lab_description, title: "Lab 3"),
          active: true,
          given_course: given_course
        })

        srfc.lab_groups << lab_group

        labs.each do |lab|
          Factory.create(:lab_has_group, {
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
      let(:examiner) { Factory.create(:examiner) }

      it "should return all non finished labs" do
        login_as(examiner)

        given_course = create(:given_course, examiners: [examiner])
        group = create(:lab_group, {
          given_course: given_course
        })

        labs = []

        # Active lab
        labs << Factory.create(:lab, {
          lab_description: Factory.create(:lab_description, title: "Lab 1"),
          active: true,
          given_course: given_course
        })

        # Non acitve lab
        labs << Factory.create(:lab, {
          lab_description: Factory.create(:lab_description, title: "Lab 2"),
          active: false,
          given_course: given_course
        })

        labs.each do |lab|
          Factory.create(:lab_has_group, {
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
      let(:assistant) { Factory.create(:assistant) }

      it "should return all non finished labs" do
        login_as(assistant)

        given_course = create(:given_course, assistants: [assistant])
        labs = []
        group = create(:lab_group, {
          given_course: given_course
        })

        # Active lab
        labs << Factory.create(:lab, {
          lab_description: Factory.create(:lab_description, title: "Lab 1"),
          active: true,
          given_course: given_course
        })

        # Non acitve lab
        labs << Factory.create(:lab, {
          lab_description: Factory.create(:lab_description, title: "Lab 2"),
          active: false,
          given_course: given_course
        })

        labs.each do |lab|
          Factory.create(:lab_has_group, {
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
      let(:admin) { Factory.create(:administrator) }

      it "should return all non finished labs" do
        login_as(admin)
        labs = []
        gc = create(:given_course)
        group = create(:lab_group, {
          given_course: gc
        })

        # Active lab
        labs << Factory.create(:lab, {
          lab_description: Factory.create(:lab_description, title: "Lab 1"),
          active: true,
          given_course: gc
        })

        # Non acitve lab
        labs << Factory.create(:lab, {
          lab_description: Factory.create(:lab_description, title: "Lab 2"),
          active: false,
          given_course: gc
        })

        labs.each do |lab|
          Factory.create(:lab_has_group, {
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
