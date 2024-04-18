Rails.application.routes.draw do
  get 'sheets_diet', to: 'sheets#sheet_diets_index'
  get 'sheets_workout', to: 'sheets#sheet_workouts_index'

  resources :sheets do
    resources :diets
    resources :workouts do
      resources :videos, only: [:destroy], module: :workouts
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live

  # Defines the root path route ("/")
  root "start#index"
end
