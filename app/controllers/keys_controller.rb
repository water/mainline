# encoding: utf-8

class KeysController < ApplicationController
  before_filter :login_required
  before_filter :find_user
  before_filter :require_current_user 
  renders_in_global_context
  before_filter :ssl_required, :only => [:index, :new, :create, :show, :destroy]

  def index
    @ssh_keys = current_user.ssh_keys
    @root = Breadcrumb::Keys.new(current_user)
    respond_to do |format|
      format.html
      format.xml { render :xml => @ssh_keys }
    end
  end
  
  def new
    @ssh_key = current_user.ssh_keys.new
    @root = Breadcrumb::NewKey.new(current_user)
  end
  
  def create
    @ssh_key = current_user.ssh_keys.new
    @ssh_key.key = params[:ssh_key].try(:[], :key)
    @root = Breadcrumb::NewKey.new(current_user)
    
    respond_to do |format|
      if @ssh_key.save
        flash[:notice] = I18n.t "keys_controller.create_notice"
        format.html { redirect_to user_keys_path(current_user) }
        format.xml  { render :xml => @ssh_key, :status => :created, :location => user_key_path(current_user, @ssh_key) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @ssh_key.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def show
    @ssh_key = current_user.ssh_keys.find(params[:id])
    
    respond_to do |format|
      format.html
      format.xml { render :xml => @ssh_key }
    end
  end

  # can't update keys since yet we'd have to to search/replace through 
  # authorized_keys
  # def edit
  #   @ssh_key = current_user.ssh_keys.find(params[:id])
  # end
  # 
  # def update
  #   @ssh_key = current_user.ssh_keys.find(params[:id])
  #   @ssh_key.key = params[:ssh_key][:key]
  #   if @ssh_key.save
  #     flash[:notice] = "Key updated"
  #     redirect_to user_path(current_user)
  #   else
  #     render :action => "new"
  #   end
  # end
  
  def destroy
    @ssh_key = current_user.ssh_keys.find(params[:id])
    if @ssh_key.destroy
      flash[:notice] = I18n.t "keys_controller.destroy_notice"
    end
    redirect_to user_keys_path(current_user) 
  end
  
  protected
    def find_user
      @user = User.find_by_login!(params[:user_id])
    end
end
