describe BlobsController do
  render_views
  let(:repository) { FactoryGirl.create(:repo_with_data) }
  
  # Test dependent on the fact that the default repo_with_data contains a Gemfile
  describe "GET blob root" do
    before :each do
      visit repository_blob_path(repository, "master/README.md", bare: 1)
    end
    
    it "doesn't crash" do
      page.status_code.should eq(200)
    end
    it "has a blob marker" do
      page.should have_selector(".blob_marker")
    end
  end
end