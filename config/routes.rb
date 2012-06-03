# encoding: utf-8

Gitorious::Application.routes.draw do
  root to: "dashboards#show"
  
  scope ":role", constraints: { role: /examiner|student|administrator|assistant|/ } do
    resource :dashboard, only: [:show]
    resources :labs
    resources :courses do
      resources :labs, only: [:show] do
        member do 
          post "/register" => "registrations#register"
          post "/join" => "labs#join"
        end
      end

      resources :lab_groups do
        collection do
          post "join" => "lab_groups#join"
          post "create" => "lab_groups#create"
        end
        resources :labs, only: [:index, :show] do
          resources :submissions, only: [:create, :new, :show, :edit, :update] do
            collection do
              match ":commit/new" => "submissions#new", via: :get, as: :new_commit
              match ":commit" => "submissions#create", via: :post, as: :create_commit
            end
            member do
              put "/review" => "reviews#review", as: :review
              post "/review" => "reviews#review", as: :review_and_comment
              get "/diffs/:id_since" => "submissions#compare", via: :get
            end
          end
        end
      end

      resources :labs
      resources :groups
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
  
  resource :sessions
  match "/login" => "sessions#new"
  match "/logout" => "sessions#destroy"

end
