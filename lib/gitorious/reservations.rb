# encoding: utf-8
module Gitorious
  class Reservations
    class << self
      def unaccounted_root_names
        [ "teams", "dashboard", "about", "login", "logout", "commit",
          "commits", "tree", "archive-tarball", "archive-zip", "contact",
          "register", "signup", "blog", "merge_request_landing_page", "activities" ]
      end

      def reserved_root_names
        @reserved_root_names ||= unaccounted_root_names + Dir[File.join(Rails.root, "public", "*")].map{|f| File.basename(f) }
      end

      def controller_names
        return @controller_names unless @controller_names.blank?
        @controller_names = Gitorious::Application.routes.routes.map {|r| r.path[/\/([^\/]+)\//, 1] }
        @controller_names.uniq!
        @controller_names.compact!
        @controller_names.delete_if {|c| c =~ /^:/ }
        @controller_names
      end

##      def projects_member_actions
##        ProjectsController.action_methods.to_a
##      end

      def project_names
        @project_names ||= reserved_root_names + controller_names
      end

 #     def repository_names
 #       actions = RepositoriesController.action_methods.to_a
 #       @repository_names ||= projects_member_actions + controller_names + actions
 #     end
    end
  end
end
