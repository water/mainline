class LabsController < ApplicationController
  # /lab_groups/:group_id/labs/
  def index
    @group = LabGroup.find(params[:group_id])
    @labs = Lab.find_by_group(params[:lab_id])
    
  end

  def show
  end
  
  def edit
  end

  def new
  end

  def create
  end

end
