describe ReviewsController do
	describe "review" do
		it "should be possible to review a submission without giving a comment" do
			lhg = FactoryGirl.create(:lab_has_group)
			sub = FactoryGirl.create(:submission, lab_has_group_id: lhg.id)
			sub.lab_has_group.reviewing!

			put :review, id: sub.id, grade: 3, state: "accepted"
			sub = Submission.find(sub.id)
			(sub.lab_has_group.grade == "3" && sub.lab_has_group.state == "accepted").should be_true
		end

		it "should be possible to review a submission with a comment" do
			lhg = FactoryGirl.create(:lab_has_group)
			sub = FactoryGirl.create(:submission, lab_has_group_id: lhg.id)
			assistant = FactoryGirl.create(:assistant)
			sub.lab_has_group.reviewing!

			post :review, id: sub.id, grade: 3, state: "accepted", comment: "comment"
			sub = Submission.find(sub.id)
			(sub.lab_has_group.grade == "3" && 
			 sub.lab_has_group.state == "accepted" &&
			 Comment.find(sub.comment_id).body == "comment" 
			).should be_true
		end
	end
end