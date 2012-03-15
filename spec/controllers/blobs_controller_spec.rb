describe BlobsController do
  render_views
  let(:repository) { Factory.create(:repo_with_data) }
  
  # Test dependent on the fact that the default repo_with_data contains a Gemfile
  describe "GET blob root" do
    it "doesn't crash" do
      visit repository_blob_path(repository, "master/Rakefiler", bare: 1)
    end
  end
end