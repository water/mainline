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
  
  scope "/:user_id", constraints: { user_id: /~.+[^\/]/} do
    scope ":project_id" do
      scope ":repository_id" do
        match "commit/:id(.:format)" => "commits#show"
      end
    end
  end
  
  scope "/:project_id", constraints: { project_id: /.+?[^\/]/ } do    
    resources :repositories do
      match "commit/:id(.:format)" => "commits#show"
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
          
  resources :users do
    resources :repositories
  end  
end