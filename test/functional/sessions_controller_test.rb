# encoding: utf-8

require_relative "../test_helper"

class SessionsControllerTest < ActionController::TestCase  
  def auth_token(token)
    CGI::Cookie.new('name' => 'auth_token', 'value' => token)
  end

  def cookie_for(user)
    auth_token users(user).remember_token
  end
  
  def setup
    @request.env['HTTPS'] = "on"
  end
  
  without_ssl_context do
    context "GET to :new" do
      setup { get :new }
      should_redirect_to_ssl
    end
    
    context "POST to :create" do
      setup { post :new }
      should_redirect_to_ssl
    end
    
    context "DELETE to :destroy" do
      setup { delete :destroy }
      should_redirect_to_ssl
    end
  end

  should " login and redirect" do
    @controller.stubs(:using_open_id?).returns(false)
    post :create, :email => "johan@johansorensen.com", :password => "test"
    assert_not_nil session[:user_id]
    assert_response :redirect
  end
    
  should " fail login and not redirect" do
    @controller.stubs(:using_open_id?).returns(false)
    post :create, :email => 'johan@johansorensen.com', :password => 'bad password'
    assert_nil session[:user_id]
    assert_response :success
  end
    
  should " logout" do
    login_as :johan
    get :destroy
    assert session[:user_id].nil?, 'nil? should be true'
    assert_response :redirect
  end
  
  should " remember me" do
    @controller.stubs(:using_open_id?).returns(false)
    post :create, :email => 'johan@johansorensen.com', :password => 'test', :remember_me => "1"
    assert_not_nil @response.cookies["auth_token"]
  end 
  
  should " should not remember me" do
    @controller.stubs(:using_open_id?).returns(false)
    post :create, :email => 'johan@johansorensen.com', :password => 'test', :remember_me => "0"
    assert_nil @response.cookies["auth_token"]
  end 
    
  should " delete token on logout" do
    login_as :johan
    get :destroy
    assert_nil @response.cookies["auth_token"]
  end
  
  should " login with cookie" do
    users(:johan).remember_me
    @request.cookies["auth_token"] = cookie_for(:johan)
    get :new
    assert @controller.send(:logged_in?)
  end
    
  should " fail when trying to login with with expired cookie" do
    users(:johan).remember_me
    users(:johan).update_attribute :remember_token_expires_at, 5.minutes.ago.utc
    @request.cookies["auth_token"] = cookie_for(:johan)
    get :new
    assert !@controller.send(:logged_in?)
  end
    
  should " fail cookie login" do
    users(:johan).remember_me
    @request.cookies["auth_token"] = auth_token('invalid_auth_token')
    get :new
    assert !@controller.send(:logged_in?)
  end
  
  should " set current user to the session user_id" do
    session[:user_id] = users(:johan).id
    get :new
    assert_equal users(:johan), @controller.send(:current_user)
  end
  
  should " show flash when invalid credentials are passed" do
    @controller.stubs(:using_open_id?).returns(false)
    post :create, :email => "invalid", :password => "also invalid"
    # response.body.should have_tag("div.flash_message", /please try again/)
    # rspec.should test(flash.now)
  end
  
  context "Setting a magic header when there's a flash message" do
    should "set the header if there's a flash" do
      post :create, :email => "johan@johansorensen.com", :password => "test"
      assert_not_nil flash[:notice]
      assert_equal "true", @response.headers["X-Has-Flash"]
    end
  end
  
  context 'Bypassing cachíng for authenticated users' do
    should 'be set when logging in' do
      post :create, :email => "johan@johansorensen.com", :password => "test"
      assert_equal "true", cookies['_logged_in']
    end
    
    should 'be removed when logging out' do
      post :create, :email => "johan@johansorensen.com", :password => "test"
      assert_not_nil cookies['_logged_in']
      delete :destroy
      assert_nil cookies['_logged_in']
    end
    
    should "remove the cookie when logging out" do
      @request.cookies["_logged_in"] = "true"
      delete :destroy
      assert_nil @response.cookies["_logged_in"]
    end
    
    should "set the logged-in cookie when logging in with an auth token" do
      users(:johan).remember_me
      @request.cookies["auth_token"] = cookie_for(:johan)
      get :new
      assert @controller.send(:logged_in?)
      assert_equal "true", @response.cookies["_logged_in"]
    end
    
    should "set the _logged_in cookie only on  succesful logins" do
      post :create, :email => "johan@johansorensen.com", :password => "lulz"
      assert_nil cookies['_logged_in']
    end
  end
end
