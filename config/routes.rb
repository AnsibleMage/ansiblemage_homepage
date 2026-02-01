Rails.application.routes.draw do
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Static pages
  root "pages#home"
  get "about" => "pages#about"
  get "projects" => "pages#projects"

  # Blog
  resources :posts, only: [:index, :show] do
    resource :likes, only: [:create, :destroy]
    resources :comments, only: [:create, :destroy]
  end

  # Authentication
  get "auth/github/callback" => "sessions#create", as: :auth_github
  get "auth/github" => "sessions#github", as: :github_login
  delete "logout" => "sessions#destroy", as: :logout

  # Admin
  namespace :admin do
    resources :posts
  end
end
