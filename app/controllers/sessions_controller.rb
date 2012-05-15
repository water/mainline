# encoding: utf-8

require "openid"
require "yadis"

# This controller handles the login/logout function of the site.
class SessionsController < ApplicationController
  layout "water"
  skip_before_filter :public_and_logged_in
  before_filter :remove_navbar
  # renders_in_site_specific_context
  force_ssl only: [:new, :create, :destroy]
  
  def new
    if User.find_by_email("admin@popfizzle.com") and params[:force]
      password_authentication("pelle", "abc123")
    else
      flash.now.alert = %q{
        Database is not popularise, 
        run seed script using CLEAR=1 rake db:seed
      }
    end
  end

  def create
    password_authentication(params[:email], params[:password])
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    clear_varnish_auth_cookie
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end

  protected

  # Prevents the navbar from being rendered
  def remove_navbar
    @no_navbar = true
  end

  # if user doesn't exist, it gets created and activated,
  # else if the user already exists with same identity_url, it just logs in
  def open_id_authentication(openid_url)
    authenticate_with_open_id(openid_url, :required => [:nickname, :email], :optional => [:fullname]) do |result, identity_url, registration|
      if result.successful?
        @user = User.find_or_initialize_by_identity_url(identity_url)
        if @user.new_record?

          session[:openid_nickname] = registration['nickname']
          session[:openid_email]    = registration['email']
          session[:openid_fullname] = registration['fullname']
          session[:openid_url]      = identity_url
          flash[:notice] = "You now need to finalize your account"
          redirect_to :controller => 'users', :action => 'openid_build' and return
        end
        self.current_user = @user
        successful_login
      else
        failed_login result.message, 'openid'
      end
    end
  rescue ActiveRecord::RecordInvalid => invalid
    flash[:error] = %Q{This login (<strong>#{@user.login}</strong>) already exists, 
      please <a href="#{@user.identity_url}"> choose a different persona/nickname 
      or modify the current one</a>}
    redirect_to login_path(:method => 'openid')
  end

  def password_authentication(email, password)
    self.current_user = User.authenticate_by_email(email, password)    
    if logged_in?
      successful_login
    else
      failed_login("Email and/or password didn't match, please try again.")
    end
  end

  def failed_login(message = "Authentication failed.",method="")
    if method==''
      flash.now[:error] = message
      render :action => 'new'
    else
      redirect_to login_path(:method=>method)
      flash[:error] = message
    end
  end

  def successful_login
    if params[:remember_me] == "1"
      self.current_user.remember_me
      cookies[:auth_token] = { 
        :value => self.current_user.remember_token , 
        :expires => self.current_user.remember_token_expires_at,
        :domain => ".#{GitoriousConfig['gitorious_host']}",
      }
    end
    check_state_and_redirect(root_path(role: :student))
  end
  
  def check_state_and_redirect(redirection_url)
      flash[:notice] = "Logged in successfully"
      redirect_back_or_default(redirection_url)
  end

end
