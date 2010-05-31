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

  resources :teams, :as => "groups" do
    delete :avatar, :on => :member

    repositories
    resources :projects do
      repositories
    end
    resources :memberships do
      get :auto_complete_for_user_login, :on => :collection
    end
  end

  resources :projects do
    repositories
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

  match "users/activate/:activation_code" => "users#activate"
  match "users/pending_activation" => "users#pending_activation"
  match "users/reset_password/:token" => "users#reset_password", :as => "reset_password"

  resources :users do
    collection do
      get :forgot_password
      post :forgot_password_create
      get :openid_build
      post :openid_create
    end

    member do
      get :feed
      get :password
      put :update_password
      delete :avatar
      get :watchlist
    end


    # RAILS3FAIL: constraints makes functional tests go haywire (no such route bladi bla)
    # scope :constraints => {:user_id => /#{User::USERNAME_FORMAT}/i} do
    scope do
      resources :keys
      resources :aliases do
        get :confirm, :on => :member
      end
      resource :license

      repositories
      resources :projects do
        repositories
      end
    end
  end

  resource :sessions
  match "/login" => "sessions#new"
  match "/logout" => "sessions#destroy"

  match "/activities" => "site#public_timeline", :as => :activity

  match "/about" => "site#about", :as => :about
  match "/about/faq" => "site#about", :as => :faq
  match "/contact" => "site#contact", :as => :contact

  namespace :admin do
    resources :user do
      member do
        put :suspend
        put :unsuspend
        put :reset_password
      end
    end
    # admin.resource :oauth_settings, :path_prefix => "/admin/projects/:project_id"
    # resource :oauth_settings
  end

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
