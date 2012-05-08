describe SubmissionsController do 
	describe "PUT notes" do
		it "should be possible for an assistant to set notes" do
			assistant = FactoryGirl.create(:assistant)
			subm = FactoryGirl.create(:submission)
			post :initial_comment, id: subm.id, input: "hej" 
			subm = Submission.find(subm.id)
			Comment.find(subm.comment_id).body.should eq("hej") 
		end
	end
end