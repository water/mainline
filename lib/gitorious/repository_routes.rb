module Gitorious
  module RepositoryRoutes
    def repositories(options = {})
      resources :repositories, options do
        member do
          get :clone
          post :create_clone
          get :writable_by
          get :config
          get :confirm_delete
          get :committers
          get :search_clones

          match "comments/commit/:sha" => "comments#commit", :as => :commit_comment, :via => :get
          match "comments/preview" => "comments#preview", :as => :comments_preview

          # #   repo.formatted_commits_feed "commits/*branch/feed.:format",
          # #       :controller => "commits", :action => "feed", :conditions => {:feed => :get}
          match "commits/*branch/feed.:format" => "commits#feed", :as => :formatted_commits_feed

          match "commits" => "commits#index", :as => :commits
          match "commits/*branch" => "commits#index", :as => :commits_in_ref
          match "commit/:id(.:format)" => "commits#show", :as => :commit
          match "trees" => "trees#index", :as => :trees
          match "trees/*branch_and_path" => "trees#show", :as => :tree
          match "trees/*branch_and_path.:format" => "trees#show", :as => :formatted_tree
          match "archive-tarball/*branch" => "trees#archive", :as => :archive_tar, :defaults => {:archive_forat => "tar.gz"}
          match "archive-zip/*branch" => "trees#archive", :as => :archive_zip, :defaults => {:archive_format => "zip"}

          match "blobs/raw/*branch_and_path" => "blobs#raw", :as => :raw_blob
          match "blobs/history/*branch_and_path" => "blobs#history", :as => :blob_history
          match "blobs/*branch_and_path" => "blobs#show", :as => :blob
        end

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
