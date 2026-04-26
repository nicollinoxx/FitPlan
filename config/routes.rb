Rails.application.routes.draw do
  get "welcome", to: "welcome#index"
  get "account", to: redirect("/identity/profile")

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
    resource :profile,            only: [:show, :edit, :update]
    resource :avatar,             only: [:update, :destroy]
    resource :healthy_metric,     except: [:destroy]
  end

  namespace :social do
    resources :profiles, only: [:index, :show] do
      member do
        post   :follow
        delete :unfollow
        get :followers
        get :followings
      end
    end
  end

  resources :sheets do
    resource :completion, only: %i[create destroy], module: :sheets

    resources :diets do
      resource :completion, only: %i[create destroy], module: :diets
    end

    resources :workouts do
      resource :completion, only: %i[create destroy], module: :workouts
      resources :videos, only: [:destroy], module: :workouts
    end

    collection do
      resources :requests, module: :sheets, only: [:index, :new, :create, :destroy] do
        patch :accept, on: :member
      end
    end
  end

  get :dashboard, to: "dashboard#index", as: :dashboard

  root 'sheets#index'
  get "set_locale/(:locale)", to: "application#set_session_locale", as: :set_locale

  get "up" => "rails/health#show", as: :rails_health_check
end
