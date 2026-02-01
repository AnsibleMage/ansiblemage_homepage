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

  # Authentication (OmniAuth)
  get "auth/:provider/callback" => "sessions#create"
  get "auth/failure" => "sessions#failure"
  delete "logout" => "sessions#destroy", as: :logout

  # Admin
  namespace :admin do
    resources :posts
  end
end
