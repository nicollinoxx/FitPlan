Rails.application.routes.draw do
  get    "home",    to: "home#index"
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
  end

  get 'sheets_diet',    to: 'sheets#sheet_diets_index'
  get 'sheets_workout', to: 'sheets#sheet_workouts_index'

  resources :sheets do
    resources :diets
    resources :workouts do
      resources :videos, only: [:destroy], module: :workouts
    end
  end

  root 'start#index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live

  # Defines the root path route ("/")
end
