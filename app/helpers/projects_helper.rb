# encoding: utf-8

module ProjectsHelper
  include RepositoriesHelper
  
  def show_new_project_link?
    if logged_in?
      if GitoriousConfig["only_site_admins_can_create_projects"] && !current_user.site_admin?
        return false
      end
    else
      return false
    end
    true
  end
  
  def wiki_permission_choices
    [
      ["Writable by everyone", Repository::WIKI_WRITABLE_EVERYONE],
      ["Writable by project members", Repository::WIKI_WRITABLE_PROJECT_MEMBERS],
    ]
  end

  def add_status_link(form_builder)
    link_to_function("Add status") do |page|
      form_builder.fields_for(:merge_request_statuses, MergeRequestStatus.new,
          :child_index => 'NEW_RECORD') do |f|
        html = render(:partial => 'merge_request_status_form',
                 :locals => { :form => f, :project_form => nil })
        page << ("$('#merge_request_statuses').append(" +
          "'#{escape_javascript(html)}'.replace(/NEW_RECORD/g, new Date().getTime()))" +
          ".find('input:last').SevenColorPicker();")
      end
    end
  end

  def remove_status_link(form_builder)
    remove_img = image_tag("silk/delete.png", :title => "Remove")
    if form_builder.object.new_record?
      # just remove it from the DOM
      link_to_function(remove_img, "$(this).parents('.merge_request_status').remove();");
    else
      # Set the proper hidden html flag to _delete
      form_builder.hidden_field(:delete) +
        link_to_function(remove_img, "$(this).parents('.merge_request_status').hide();
          $(this).prev().val('1')")
    end
  end 
end
