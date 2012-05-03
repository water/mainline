describe Comment do
	describe "relations" do
		it "should be possible to create a comment" do
			Factory.build(:comment).should be_valid
		end

		it "should be possible to update comments" do
			comment = Factory.create(:comment, body: "hej")	
			comment.body = "hej hej"
			comment.save
			comment.body.should eq("hej hej")
		end

		it "should not be possible for a comment to not have a user" do
			Factory.build(:comment, user: nil).should_not be_valid
		end

		it "should not be possible to create a comment with an empty body" do
			Factory.build(:comment, body: nil).should_not be_valid
		end
	end
end