# encoding: utf-8

Gitorious::Application.routes.draw do
  post "upload" => "uploads#upload"
  get "new_upload" => "uploads#new"

  post "commit_requests/new" => "commit_requests#new", :as => :commit_request

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
      resources :repositories
  end
     
  resources :groups do
      resources :repositories do
        resources :commits, :trees
      end
    resources :repositories
  end
    
  scope "/:user_id" do
      scope ":repository_id" do
        match "commit/:id(.:format)" => "commits#show"
      end
  end
   
  
  
  match "/site/dashboard" => "site#dashboard"
  
  resources :commit_lists do
      resources :repositories do
        resources :merge_requests
      end
  end
  
  resources :versions do
      resources :repositories do
        resources :merge_requests
      end
  end
end
