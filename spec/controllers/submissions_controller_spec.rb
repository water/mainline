describe SubmissionsController do 
	describe "PUT notes" do
		it "should be possible for an assistant to set notes" do
			assistant = Factory.create(:assistant)
			login_as(assistant)
			subm = Factory.create(:submission)
			post :notes, id: subm.id, notes: "hej"
			subm.notes.should eq("hej") 
		end
	end
end