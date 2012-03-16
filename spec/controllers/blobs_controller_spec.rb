describe BlobsController do
  render_views
  let(:repository) { Factory.create(:repo_with_data) }
  
  # Test dependent on the fact that the default repo_with_data contains a Gemfile
  describe "GET blob root" do
    it "has a blob marker" do
      visit repository_blob_path(repository, "master/Rakefile", bare: 1)
      page.should have_selector(".blob_marker")
    end
  end
end