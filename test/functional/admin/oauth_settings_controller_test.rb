# encoding: utf-8
require File.dirname(__FILE__) + '/../../test_helper'

class Admin::OauthSettingsControllerTest < ActionController::TestCase
  context 'On get to edit' do

    should 'grant site admins access' do
      login_as(:johan)
      get :edit, :project_id => projects(:johans).slug
      assert_response :success
    end
    
    should 'deny access to non admin users' do
      login_as(:mike)
      get :edit, :project_id => projects(:johans).slug
      assert_response :redirect
    end
  end
  
  context 'On put to update' do
    setup {
      @project = projects(:johans)
    }
    
    should 'accept new oauth settings and redirect' do
      login_as :johan
      new_settings = {
        :path_prefix      => '/foo',
        :signoff_key      => 'kee',
        :signoff_secret   => 'secret',
        :site             => 'http://oauth.example.com/'
      }
      put :update, :project_id => @project.to_param, :oauth_settings => new_settings
      assert_redirected_to :action => :edit, :project_id => @project.to_param
      assert_equal new_settings, @project.reload.oauth_settings
    end
  end
  
  context 'On get to show' do
    should 'redirect to edit' do
      project = projects(:johans)
      login_as :johan
      get :show, :project_id => project.to_param
      assert_redirected_to :action => :edit, :project_id => project.to_param
    end
  end
end
