describe RegistrationController do

	describe "register" do
		it "should be possible to use method register" do
			given_course = FactoryGirl.create(:given_course)
			lab = FactoryGirl.create(:lab, active: true, given_course_id: given_course.id)
			post :register, lab_id: lab.id, course_id: given_course.id

			LabHasGroup.find_by_lab_id(lab.id).lab_id.should eq(lab.id)
		end
	end
end