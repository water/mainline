class GroupsController < ApplicationController

  #
  # GET /courses/:course_id/groups/:group_id
  #
  def show
    @group = current_role.lab_groups.find_by_course_and_group(params.merge({
      group_id: params[:id]
    })).includes(:submissions, given_course: { labs: :lab_description }).first
  end
end