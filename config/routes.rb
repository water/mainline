# encoding: utf-8

Gitorious::Application.routes.draw do
  resources :registered_courses, :dashboards, :students
  resources :lab_deadlines, :study_periods, :course_codes

  scope ":role", constraints: { role: /examiner|student|administrator|assistant|/ } do
    resources :labs
    resources :dashboards, only: [:index]
    resources :courses do
      resources :labs, only: [:show]
      post "/courses/:course_id/upload" => "uploads#upload"
      resources :lab_groups do
        collection do
          post "join" => "lab_groups#join"
          post "create" => "lab_groups#create"
          put ":lab_id/register" => "lab_groups#register"
        end
        resources :labs, only: [:index, :show] do
          resources :submissions, only: [:create, :new, :show, :edit, :update] do
            collection do
              match ":commit/new" => "submissions#new", via: :get, as: :new_commit
              match ":commit" => "submissions#create", via: :post, as: :create_commit
            end
            member do
              put "/review" => "reviews#review", as: :review
            end
          end
        end
      end
    end
  end
 
  post "upload" => "uploads#upload"

  # /lab_groups/:group_id/labs/:lab_id/submissions/new
  resources :lab_groups do
    resources :labs, only: [:index, :show] do
      match "join" => "labs#join"
      resources :submissions, only: [:index, :show]
    end
  end

  resources :comments, only: [:show, :create, :new, :destroy, :edit, :update]

  resources :submissions, only: [:index, :show, :create, :new]
  
  resources :repositories do
    match "blobs/raw/*branch_and_path" => "blobs#raw", as: :raw_blob, format: false
    match "commits/*branch" => "commits#index", as: :commits_in_ref
    match "trees/*branch_and_path" => "trees#show", as: :tree, format: false
    match "blobs/*branch_and_path" => "blobs#show", as: :blob, format: false
    match "blobs/history/*branch_and_path" => "blobs#history", as: :blob_history, format: false
    match "commit/:id(.:format)" => "commits#show", as: :commit
    resources :commit_requests, only: [:create]
  end
  
  extend Gitorious::RepositoryRoutes
  
  root :to => "dashboards#index"
  
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
