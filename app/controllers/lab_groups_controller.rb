class LabGroupsController < ApplicationController
  respond_to :html
  def index
  end

  def show
    @lab_group = LabGroup.find(params[:id])
    @labs = @lab_group.labs
    respond_with(@lab_group)
  end

  def new
  end

  def create
  end

  def edit
  end
end
