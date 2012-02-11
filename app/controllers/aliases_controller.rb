# encoding: utf-8
class AliasesController < ApplicationController
  before_filter :login_required
  before_filter :find_user
  before_filter :require_current_user
  renders_in_global_context
  
  def index
    @emails = @user.email_aliases
    @root = Breadcrumb::Aliases.new(current_user)
  end
  
  def new
    @email = @user.email_aliases.new
    @root = Breadcrumb::NewAlias.new(current_user)
  end
  
  def create
    @email = @user.email_aliases.new(params[:email])
    
    if @email.save
      flash[:success] = "You will receive an email asking you to confirm ownership of #{@email.address}"
      redirect_to user_aliases_path(@user)
    else
      render "new"
    end
  end
  
  def confirm
    email = current_user.email_aliases.with_aasm_state(:pending).where("confirmation_code = ?", params[:id]).
      first
    if email
      email.confirm!
      flash[:success] = "#{email.address} is now confirmed as belonging to you"
      redirect_to user_aliases_path(@user) and return
    else
      flash[:error] = "The confirmation is incorrect"
      redirect_to user_path(@user)
    end
  end
  
  def destroy
    @email = @user.email_aliases.find_by_id(params[:id])
    if @email.destroy
      flash[:success] = "Email alias deleted"
    end
    redirect_to user_aliases_path(@user)
  end
  
  protected
    def find_user
      @user = User.find_by_login!(params[:user_id])
    end
end
