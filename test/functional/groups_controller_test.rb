# encoding: utf-8

require_relative "../test_helper"

class GroupsControllerTest < ActionController::TestCase
  
  should_render_in_global_context

  def setup
    @group = groups(:team_thunderbird)
  end
  
  context "Routing" do
    should "recognizes routes starting with plus as teams/show/<name>" do
      assert_generates("/+#{@group.to_param}", { :controller => "groups", 
        :action => "show", :id => @group.to_param})
      assert_recognizes({:controller => "groups", :action => "show", 
                         :id => @group.to_param}, "/+#{@group.to_param}")
    end
  end
  
  context "GET index" do
    should "it is successfull" do
      get :index
      assert_response :success
    end
  end
  
  context "GET show" do
    should "finds the requested group" do
      get :show, :id => @group.to_param
      assert_response :success
      assert_equal @group, assigns(:group)
    end
  end
  
  context 'GET to edit' do
    setup do
      login_as :mike
      get :edit, :id => @group.to_param
    end
    should_assign_to :group
    should_respond_with :success
  end
  
  context 'PUT do update' do
    should 'require user to be admin of group' do
      put :update, :id => @group.to_param, :group => {:description => "Unskilled and unprofessional"}
      assert_redirected_to :controller => 'sessions', :action => 'new'
    end
    
    should 'only update the description, not the name' do
      login_as :mike
      put :update, :id => @group.to_param, :group => {:name => 'hackers'}
      assert_redirected_to :action => 'show'
      assert_equal('team-thunderbird', @group.name)
    end
    
    should 'update successfully' do
      login_as :mike
      new_description = 'We save lives'
      put :update, :id => @group.to_param, :group => {:description => new_description}
      assert_redirected_to :action => 'show'
      assert_equal(new_description, @group.reload.description)
    end
  end
  
  context "creating a group" do
    should "requires login" do
      get :new
      assert_redirected_to (new_sessions_path)
    end
    
    should "GETs new successfully" do
      login_as :mike
      get :new
      assert_response :success
    end
    
    should "POST create creates a new group" do
      login_as :mike
      assert_difference("Group.count") do
        post :create, :group => {:name => "foo-hackers", :description => 'Hacking the foos for your bars'},
          :project => {:slug => projects(:johans).slug}
      end
      assert_not_equal nil, flash[:success]
      assert !assigns(:group).new_record?, 'assigns(:group).new_record? should be false'
      assert_equal "foo-hackers", assigns(:group).name
      assert_equal [users(:mike)], assigns(:group).members
    end
  end
  
  context "deleting a group" do
    setup do
      @group = groups(:team_thunderbird)
      @user = users(:mike)
      assert @group.admin?(@user)
    end
    
    should "be deletable if there's only one member" do
      assert_equal 1, @group.members.count
      login_as :mike
      @group.projects.destroy_all
    
      assert_difference("Group.count", -1) do
        delete :destroy, :id => @group.to_param
        assert_response :redirect
      end
      assert_redirected_to groups_path
      assert_match(/team was deleted/, flash[:success])
    end
    
    should "not be deletable if there's more than one member" do
      @group.add_member(users(:johan), Role.member)
      assert_equal 2, @group.members.count
      login_as :mike
      assert_no_difference("Group.count", -1) do
        delete :destroy, :id => @group.to_param
        assert_response :redirect
      end
      assert_redirected_to group_path(@group)
      assert_match(/team can't be deleted/, flash[:error])
    end
    
    should "be deletable if there's more than one member and user is site_admin" do
      assert users(:johan).site_admin?
      @group.add_member(users(:johan), Role.member)
      assert_equal 2, @group.members.count
      
      login_as :johan
      assert_difference("Group.count", -1) do
        delete :destroy, :id => @group.to_param
      end
      assert_response :redirect
      assert_redirected_to groups_path
      assert_match(/team was deleted/, flash[:success])
    end
    
    should 'be able to delete the team avatar' do
      login_as :mike
      @group.update_attribute(:avatar_file_name, "foo.png")
      assert @group.avatar?
      delete :avatar, :id => @group.to_param
      assert_redirected_to group_path(@group)
      assert !@group.reload.avatar?
    end
  end
end
