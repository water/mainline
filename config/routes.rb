# encoding: utf-8
#--
#   Copyright (C) 2009 Nokia Corporation and/or its subsidiary(-ies)
#   Copyright (C) 2007, 2008, 2009 Johan Sørensen <johan@johansorensen.com>
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

Gitorious::Application.routes.draw do |map|
  extend Gitorious::RepositoryRoutes

  root :to => "site#index"
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
    resources :repositories
  end
  
  # match "/projects/:project_id/repositories" => "repositories#index"
  
  # match "/:project_id/repositories/new" => "repositories#new"
  # match "/:project_id/repositories" => "repositories#index"
  # match "/:project_id/repositories/edit" => "repositories#edit"
  # match "/:project_id/repositories" => "repositories#update"
  
  
  #match "/:id/edit" => "projects#edit"
  #match "/:id(/:format)" => "projects#show"
  #match "/projects/update" => "projects#update"
  
  scope "/:project_id" do
    resources :repositories
  end
  
 # 
 # The recognized options <{"controller"=>"projects",
 #  "action"=>"show",
 #  "id"=>"johans-project",
 #  "format"=>"repositories"}> did not match <{"controller"=>"repositories",
 #  "action"=>"index",
 #  "project_id"=>"johans-project"}>, difference: <{"controller"=>"repositories",
 #  "action"=>"index",
 #  "project_id"=>"johans-project",
 #  "id"=>"johans-project",
 #  "format"=>"repositories"}>.
 #  

 # resources :projects, 
  
  resources :projects do
    member do
      get :clones
      put :preview
      get :edit_slug
      get :confirm_delete

      get :clone
      post :create_clone
      get :writable_by
      get :configure
      get :committers
      get :search_clones  
    end
    
    resources :pages
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
    end
  end
  
  resources :users do
    resources :repositories
  end
  
  resources_with_custom_prefix :projects do
    repositories
  end
         
#The recognized options <{"controller"=>"projects", "action"=>"show", "project_id"=>"johans-project"}> 
#did not match <{"controller"=>"projects", "action"=>"show", "id"=>"johans-project"}>, 

#difference: <{"id"=>"johans-project", "pro
          
          
                  #The recognized options <{"controller"=>"repositories", "action"=>"new", "id"=>"johans-project"}> did not match 
                  #<{"controller"=>"repositories", "action"=>"new", "project_id"=>"johans-project"}>, difference: <{"project_id"=>"johans-project", "id"=>"johans-project"}>.
                  
                  
#                  The recognized options <{"controller"=>"repositories", "action"=>"index", "id"=>"johans-project"}> did not match <{"controller"=>"repositories",
 #                          "action"=>"index",
  #                         "project_id"=>"johans-project"}>, difference: <{"project_id"=>"johans-project", "id"=>"johans-project"}>.
  
  
#The recognized options <{"controller"=>"projects",
#   "action"=>"show",
#   "id"=>"johans-project",
#   "format"=>"repositories"}> did not match <{"controller"=>"repositories",
#   "action"=>"index",
#   "project_id"=>"johans-project"}>, difference: <{"controller"=>"repositories",
#   "action"=>"index",
#   "project_id"=>"johans-project",
#   "id"=>"johans-project",
#   "format"=>"repositories"}>.
#                  

  #match "/:id(/:format)" => "projects#show"  
end
