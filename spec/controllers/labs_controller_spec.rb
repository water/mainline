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

  def login_as(role)
    visit new_sessions_path
    fill_in "Email", with: role.user.email
    fill_in "Password", with: role.user.password
    click_button "Log in"
  end

  describe "GET /labs" do
    describe "student" do
      let(:student) { Factory.create(:student) }

      it "should return all not finished labs" do
        login_as(student)

        srfc = Factory.create(:student_registered_for_course, {
          student: student
        })

        lab_group = Factory.create(:lab_group)
        labs = []

        # Active lab
        labs << Factory.create(:lab, {
          lab_description: Factory.create(:lab_description, title: "Lab 1"),
          active: true
        })

        # Non acitve lab
        labs << Factory.create(:lab, {
          lab_description: Factory.create(:lab_description, title: "Lab 2"),
          active: false
        })

        # Non related lab
        Factory.create(:lab, {
          lab_description: Factory.create(:lab_description, title: "Lab 3"),
          active: true
        })

        srfc.lab_groups << lab_group

        labs.each do |lab|
          Factory.create(:lab_has_group, {
            lab: lab,
            lab_group: lab_group
          })
        end

        visit labs_path

        page.should have_content("Lab 1")
        page.should_not have_content("Lab 2")
        page.should_not have_content("Lab 3")
        page.should have_content(labs.first.description)
      end
    end
  end
end
