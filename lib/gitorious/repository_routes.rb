module Gitorious
  module RepositoryRoutes
    class CustomPrefixResource < ActionDispatch::Routing::Mapper::Resource
      attr_accessor :prefix

      def member_scope
        ["#{prefix}:id", options]
      end

      def nested_path
        "#{prefix}:#{singular}_id"
      end
    end

    def resources_with_custom_prefix(name, prefix = nil, options = {}, &block)
      if @scope[:scope_level] == :resources
        nested do
          resources_with_custom_prefix(name, nil, options, &block)
        end
        return
      end

      resource = CustomPrefixResource.new(name, options)
      resource.prefix = prefix
      resource_scope(:resources, resource) do
        yield if block_given?
      end
    end

    def repositories
      return 
      resources_with_custom_prefix :repositories do
        member do
          get :clone
          post :create_clone
          get :writable_by
          get :configure
          get :confirm_delete
          get :committers
          get :search_clones

          match "trees" => "trees#index", :as => :trees
          match "trees/*branch_and_path.:format" => "trees#show", :as => :formatted_tree
          match "archive-tarball/*branch" => "trees#archive", :as => :archive_tar, :defaults => {:archive_format => "tar.gz"}
          match "archive-zip/*branch" => "trees#archive", :as => :archive_zip, :defaults => {:archive_format => "zip"}
        end

        # Make some of these member-ish routes act as if they were on a
        # nested controller, causing :repository_id instead of :id.
        with_scope_level :member do
          #scope ":repository_id", :name_prefix => parent_resource.member_name, :as => "" do
          #  match "comments/commit/:sha" => "comments#commit", :as => :commit_comment, :via => :get
          #  match "comments/preview" => "comments#preview", :as => :comments_preview

            # #   repo.formatted_commits_feed "commits/*branch/feed.:format",
            # #       :controller => "commits", :action => "feed", :conditions => {:feed => :get}
          #  match "commits/*branch/feed.:format" => "commits#feed", :as => :formatted_commits_feed
          #  match "commits" => "commits#index", :as => :commits
          #end
        end

        resources :comments

        resources :merge_requests do
          member do
            get :terms_accepted
            get :version
            get :commit_status
          end

          collection do
            post :create
            post :commit_list
            post :target_branches
          end

          resources :comments do
            post :preview, :on => :collection
          end

          resources :merge_request_versions do
            resources :comments do
              post :preview, :on => :collection
            end
          end
        end

        resources :committerships do
          collection do
            get :auto_complete_for_group_name
            get :auto_complete_for_user_login
          end
        end
      end
    end
  end
end
