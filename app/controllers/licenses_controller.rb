# encoding: utf-8

class LicensesController < ApplicationController
  before_filter :login_required
  skip_before_filter :require_current_eula
  
  def show
    if !current_user.terms_accepted?
      flash[:notice] = t("views.license.terms_not_accepted")
      redirect_to :action => 'edit' and return
    end
  end
  
  def edit
    if current_user.terms_accepted?
      flash[:notice] = t("views.license.terms_already_accepted")
      redirect_to :action => :show and return
    end
  end
  
  def update
    current_user.terms_of_use = params[:user][:terms_of_use]
    if !current_user.terms_of_use.blank?
      current_user.save!
      flash[:success] = t("views.license.terms_accepted")
      if !current_user.terms_of_use.blank?
        current_user.accept_terms
      end
      redirect_back_or_default :action => :show
    else
      flash[:error] = t("views.license.terms_not_accepted")
      redirect_to :action => :edit
    end
  end
  
end
