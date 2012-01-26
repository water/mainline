# encoding: utf-8
#--
#   Copyright (C) 2009 Nokia Corporation and/or its subsidiary(-ies)
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Affero General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU Affero General Public License for more details.
#
#   You should have received a copy of the GNU Affero General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#++
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

      def projects_member_actions
        ProjectsController.action_methods.to_a
      end

      def project_names
        @project_names ||= reserved_root_names + controller_names
      end

      def repository_names
        actions = RepositoriesController.action_methods.to_a
        @repository_names ||= projects_member_actions + controller_names + actions
      end
    end
  end
end
