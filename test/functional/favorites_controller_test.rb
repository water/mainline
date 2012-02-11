# encoding: utf-8

require_relative "../test_helper"

class FavoritesControllerTest < ActionController::TestCase
  def do_create_post(type, id, extra_options={})
    post :create, extra_options.merge(:watchable_type => type,
      :watchable_id => id)
  end

  context "Creating a new favorite" do
    setup {
      login_as :johan
      @repository = repositories(:johans2)
    }

    should "require login" do
      session[:user_id] = nil
      post :create
      assert_redirected_to new_sessions_path
    end

    should "assign to watchable" do
      do_create_post(@repository.class.name, @repository.id)
      assert_response :redirect
      assert_equal @repository, assigns(:watchable)
    end

    should "render not found when missing watchable" do
      do_create_post(@repository.class.name, 999)
      assert_response :not_found
    end

    should "render not found when invalid watchable type is provided" do
      do_create_post("RRepository", @repository.id)
      assert_response :not_found
    end

    should "create a favorite" do
      do_create_post(@repository.class.name, @repository.id)
      assert_not_nil(favorite = assigns(:favorite))
    end

    should "redirect to the watchable itself" do
      do_create_post(@repository.class.name, @repository.id)
      assert_redirected_to([@repository.owner, @repository.project, @repository])
    end

    context "JS requests" do
      should "render :created" do
        do_create_post(@repository.class.name, @repository.id, {:format => "js"})
        assert_response :created
      end

      should "render :not_found" do
        do_create_post("Rrepository", @repository.id)
        assert_response :not_found
      end

      should "supply deletion URL in Location:" do
        do_create_post(@repository.class.name, @repository.id, {:format => "js"})
        assert_not_nil(favorite = assigns(:favorite))
        assert_equal("/favorites/#{favorite.id}", @response.headers["Location"])
      end
    end
  end

  context "Watching a merge request" do
    setup {
      login_as :johan
      @merge_request = merge_requests(:moes_to_johans)
    }

    should "create it" do
      do_create_post(@merge_request.class.name, @merge_request.id,
        {:format => "js"})
      assert_response :created
    end

    should "destroy it" do
      favorite = users(:johan).favorites.create(:watchable => @merge_request)
      delete :destroy, :id => favorite, :format => "js"
      assert_response :ok
    end
  end

  context "Deleting a favorite" do
    setup {
      login_as :johan
      @repository = repositories(:johans2)
      @favorite = users(:johan).favorites.create(:watchable => @repository)
    }

    should "assign to favorite" do
      delete :destroy, :id => @favorite
      assert_equal @favorite, assigns(:favorite)
    end

    should "redirect for HTML" do
      delete :destroy, :id => @favorite
      assert_redirected_to([@repository.owner, @repository.project, @repository])
    end

    should "render :deleted for JS" do
      delete :destroy, :id => @favorite, :format => "js"
      assert_response :ok
    end

    should "supply re-creation URL in Location:" do
      delete :destroy, :id => @favorite, :format => "js"
      assert_equal(
        favorites_path(:watchable_id => @repository.id, :watchable_type => "Repository"),
        @response.headers["Location"])
    end

    should "delete the favorite" do
      delete :destroy, :id => @favorite
      assert_raises ActiveRecord::RecordNotFound do
        Favorite.find(@favorite.id)
      end
    end
  end

  context "listing a users own favorites" do
    setup do
      @user = users(:mike)
      repositories(:johans).watched_by!(@user)
      login_as :mike
    end

    should "require login" do
      login_as nil
      get :index
      assert_redirected_to new_sessions_path
    end

    should "only list the users favorites" do
      assert @user.favorites.count > 0, "user has no favs"
      other_fav = Favorite.create!({:user => users(:johan),
          :watchable => Repository.last})
      get :index
      assert !assigns(:favorites).include?(other_fav)
      assert_equal @user.favorites, assigns(:favorites)
      assert_response :success
    end

    should "have a button to toggle the mail flag" do
      get :index
      assert_response :success
      assert_select "td.notification .favorite a.toggle"
    end

    should "have a button to delete the favorite" do
      get :index
      assert_response :success
      assert_select "td.unwatch .favorite a.watch-link"
    end
  end

  context "editing a favorite" do
    setup do
      @user = users(:mike)
      login_as @user
      @favorite = Repository.last.watched_by!(@user)
    end

    should "scope the find to the user" do
      fav = Favorite.create!({:user => users(:johan),
          :watchable => Repository.last})
      put :update, :id => fav.id
      assert_response :not_found
    end

    should "be able to add the mail flag" do
      assert !@favorite.notify_by_email?
      get :update, :id => @favorite.id, :favorite => {:notify_by_email => true}
      assert_response :redirect
      assert_redirected_to favorites_path
      assert @favorite.reload.notify_by_email?
    end

    should "only be able to change the mail flag" do
      assert !@favorite.notify_by_email?
      get :update, :id => @favorite.id, :favorite => {:user_id => users(:johan).id}
      assert_response :redirect
      assert_equal @user, @favorite.reload.user
    end
  end
end
