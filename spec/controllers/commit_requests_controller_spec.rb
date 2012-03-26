describe CommitRequestsController do
  let(:content) { JSON.parse(response.body) }
  let(:repository) { Factory.create(:repository) }

  describe "POST create" do
    it "should respond with 201 on valid request" do
      user = create(:administrator)
      login_as(user)
      post(:create, {
        format: "json",
        repository_id: repository.id,
        commit_request: {
          user: user.user.id,
          command: "add",
          branch: "master"
        }
      })
      response.status.should eq(201)
      content.keys.should_not include("errors")
    end

    it "should respond with 422 on invalid request" do
      user = create(:student)
      login_as(user)
      CommitRequest.any_instance.stubs(:valid?).returns(false)
      post(:create, { 
        format: "json", 
        repository_id: repository.id, 
        commit_request: {}
      })
      response.status.should equal(422)
      content.keys.should include("errors")
    end
  end
end
