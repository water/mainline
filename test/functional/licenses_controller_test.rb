# encoding: utf-8

require_relative "../test_helper"

class LicensesControllerTest < ActionController::TestCase
  context 'Accepting (current) end user license agreement' do
    setup do
      @user = users(:old_timer)
      login_as :old_timer
    end

    should "GET show redirect to edit with a flash" do
      get :show, :user_id => @user.id
      assert_response :redirect
      assert_match(/You need to accept the/, flash[:notice])
    end
    
    should 'render the current license version if this has been accepted' do
      @user.accept_terms!
      get :edit, :user_id => @user.id
      assert_redirected_to :action => :show
    end
    
    should 'ask the user to confirm a newer version if this has not been acccepted' do
      get :edit, :user_id => @user.id
      assert_response :success
    end
    
    should 'require the user to accept the terms' do
      put :update, :user => {}, :user_id => @user.id
      assert_redirected_to :action => :edit
    end
    
    should 'change the current version when selected' do
      put :update, :user => { :terms_of_use => "1" }, :user_id => @user.id
      assert_redirected_to :action => :show
      assert @user.reload.terms_accepted?
    end
    
    should "not change the current version if not selected" do
      put :update, :user => {:terms_of_use => ""}, :user_id => @user.id
      assert !@user.reload.terms_accepted?
      assert_match(/You need to accept the/, flash[:error])
    end
  end
end
