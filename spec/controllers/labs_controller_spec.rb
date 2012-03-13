describe LabsController do
  describe "POST join" do
    it "should test join action" do
      student = Factory.create(:student)
      group = Factory.create(:lab_group)
      lab = Factory.create(:lab)
      labhasgroup = Factory.create(:lab_has_group)
      post :join, lab_group: group.id, lab_id: lab.id
    end
  end
end
