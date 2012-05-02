describe TreesController do
  render_views
  let(:repository) { FactoryGirl.create(:repo_with_data) }
  
  describe "GET tree root" do
    it "displays a table" do
      visit repository_tree_path(repository, "master", bare: 1)
      page.should have_selector("table")
    end
  end
end