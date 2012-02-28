# encoding: utf-8

Gitorious::Application.routes.draw do
  resources :submissions, :only => [:index, :show, :create, :new]

  extend Gitorious::RepositoryRoutes
  
  root :to => "site#index"
  
  resources :merge_requests
  
  resources :merge_requests do
    member do
      get :version
      get :commit_status
      get :terms_accepted
    end
  end
    
  scope "/+:group_id" do
    resources :memberships
  end
  
  resources :events do
    get :commits, :on => :member
  end

  resource :search

  resources :favorites

  resources :messages do
    member do
      post :reply
      put :read
    end

    collection do
      get :auto_complete_for_message_recipients
      get :sent
      put :bulk_update
      get :all
    end
  end
  
  resources :users do
    collection do
      put :update
      get :reset_password
      get :forgot_password
      get :edit
    end
    
    resources :projects do
      resources :repositories
    end
    resources :repositories
  end
    
  match "users/activate/:activation_code" => "users#activate"
  match "users/pending_activation" => "users#pending_activation"
  match "users/reset_password/:token" => "users#reset_password", :as => "reset_password"

  match "/merge_request_landing_page" => "merge_requests#oauth_return"
  match "/merge_requests/:id" => "merge_requests#direct_access"

  resource :sessions
  match "/login" => "sessions#new"
  match "/logout" => "sessions#destroy"

  match "/activities" => "site#public_timeline", :as => :activity

  match "/about" => "site#about", :as => :about
  match "/about/faq" => "site#about", :as => :faq
  match "/contact" => "site#contact", :as => :contact

  namespace :admin do
    resources :users do
      member do
        put :suspend
        put :unsuspend
        put :reset_password
      end
    end
  end

  resources_with_custom_prefix :users, "~" do
    member do
      get :feed
      get :password
      put :update_password
      delete :avatar
      get :watchlist
    end

    collection do
      get :forgot_password
      post :forgot_password_create
      get :openid_build
      post :openid_create
    end

    scope do
      resources :keys
      resources :aliases do
        get :confirm, :on => :member
      end
      resource :license

      repositories

      resources_with_custom_prefix :projects do
        repositories
      end
    end
  end

  resources_with_custom_prefix :groups, "+" do
    delete :avatar, :on => :member

    resources :memberships do
      get :auto_complete_for_user_login, :on => :collection
    end

    repositories

    resources_with_custom_prefix :projects do
      repositories
    end
  end
    
  resources :groups do
    resources :projects do
      resources :repositories
    end
  end
     
  resources :groups do
    resources :projects do
      resources :repositories do
        resources :commits, :trees
      end
    end
    resources :repositories
  end
  
  scope "/:project_id", constraints: { project_id: /.+?[^\/]/ } do    
    resources :repositories do
      match "commit/:id(.:format)" => "commits#show"
      #match "trees" => "trees#index", :as => :trees
      #match "trees/*branch_and_path.:format" => "trees#show", :as => :formatted_tree      
    end
  end
    
  scope "/:user_id" do
    scope ":project_id" do
      scope ":repository_id" do
        match "commit/:id(.:format)" => "commits#show"
      end
    end
  end
   
  resources :projects do
    member do
      get :clones
      put :preview
      get :edit_slug
      put :update
      get :clone
      post :create_clone
      get :writable_by
      get :configure
      get :committers
      get :search_clones  
      delete :destroy
      put :update
      get :edit
    end
    
    collection do
      get :confirm_delete
      delete :destroy
      put :update
    end
    
    resources :pages do
      member do
        get :preview
      end
    end
    
    resources :merge_requests do
      resources :merge_request_version
    end
    
    resources :repositories do
      match "blobs/raw/*branch_and_path" => "blobs#raw", :as => :raw_blob
      match "commits/*branch" => "commits#index", :as => :commits_in_ref
      match "trees/*branch_and_path" => "trees#show", :as => :tree
      match "blobs/*branch_and_path" => "blobs#show", :as => :blob
      match "blobs/history/*branch_and_path" => "blobs#history", :as => :blob_history
      match "commit/:id(.:format)" => "commits#show", :as => :commit
      
      match "comments/commit/:sha" => "comments#commit", :as => :commit_comment, :via => :get
      match "comments/preview" => "comments#preview", :as => :comments_preview
      match "commits/*branch/feed.:format" => "commits#feed", :as => :formatted_commits_feed
      match "commits" => "commits#index", :as => :commits
      
      match "trees" => "trees#index", :as => :trees
      match "trees/*branch_and_path.:format" => "trees#show", :as => :formatted_tree
      resources :comments
      
      resources :trees do
        collection do
          get :archive
        end
      end
            
      resources :merge_requests do
        
        # {:project_id=>"johans-project", :repository_id=>"johansprojectrepos", :merge_request=>{:target_repository_id=>1}, :controller=>"merge_requests", :action=>"target_branches"}
        collection do
          get :target_branches
        end
        resources :merge_request_version
      end
      
      resources :commits do
        member do
          get :feed
        end
      end
      resources :merge_requests do
        resources :comments
      end
      
      member do
        get :clone
        post :create_clone
        get :writable_by
        get :configure
        get :confirm_delete
        get :committers
        get :search_clones
      end
      
      collection do
        get :config
      end      

      match "trees" => "trees#index", :as => :trees
      match "trees/*branch_and_path.:format" => "trees#show", :as => :formatted_tree
      match "archive-tarball/*branch" => "trees#archive", :as => :archive_tar, :defaults => {:archive_forat => "tar.gz"}
      match "archive-zip/*branch" => "trees#archive", :as => :archive_zip, :defaults => {:archive_format => "zip"}
      
      resources :committerships do
        collection do
          get :auto_complete_for_user_login
          get :auto_complete_for_group_name
        end
      end
    end
  end
  
  resources :projects, path: ""
  
  match "/site/dashboard" => "site#dashboard"
  
  resources :commit_lists do
    resources :projects do
      resources :repositories do
        resources :merge_requests
      end
    end
  end
  
  resources :versions do
    resources :projects do
      resources :repositories do
        resources :merge_requests
      end
    end
  end
end