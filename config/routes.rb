Rails.application.routes.draw do
  get "account", to: "account#index"
  resources :user_details, except: [:destroy]

  get    "sign_in", to: "sessions#new"
  post   "sign_in", to: "sessions#create"
  get    "sign_up", to: "registrations#new"
  post   "sign_up", to: "registrations#create"
  resources :sessions, only: [:index, :show, :destroy]
  resource  :password, only: [:edit, :update]
  namespace :identity do
    resource  :email,              only: [:edit, :update]
    resource  :email_verification, only: [:show, :create]
    resource  :password_reset,     only: [:new,  :edit, :create, :update]
    resources :avatars,            only: [:show, :edit, :update, :destroy]
    resource  :profile,            only: [:edit, :update]
  end

  resources :sheets do
    resources :diets
    resources :workouts do
      resources :videos, only: [:destroy], module: :workouts
    end
  end

  namespace :shares do
    resources :shared_sheets, only: [:index, :new, :create, :destroy] do
      patch :accept, on: :member
    end
  end

  root 'sheets#index'
  get "set_locale/(:locale)", to: "application#set_session_locale", as: :set_locale
end
