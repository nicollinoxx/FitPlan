Rails.application.routes.draw do
  get "account", to: "account#index"

  get    "sign_in", to: "sessions#new"
  post   "sign_in", to: "sessions#create"
  get    "sign_up", to: "registrations#new"
  post   "sign_up", to: "registrations#create"
  resources :sessions, only: [:index, :show, :destroy]
  resource  :password, only: [:edit, :update]
  namespace :identity do
    resource :email,              only: [:edit, :update]
    resource :email_verification, only: [:show, :create]
    resource :password_reset,     only: [:new,  :edit, :create, :update]
    resource :profile,            only: [:edit, :update]
    resource :avatar,            except: [:new, :create]
    resource :healthy_metric,     except: [:destroy]
  end

  resources :sheets do
    resources :diets
    resources :workouts do
      resources :videos, only: [:destroy], module: :workouts
    end
  end

  resources :sheet_requests, only: [:index, :new, :create, :destroy] do
    patch :accept, on: :member
  end

  root 'sheets#index'
  get "set_locale/(:locale)", to: "application#set_session_locale", as: :set_locale
end
