Rails.application.routes.draw do

  resources :diets
  resources :fichas do
    resources :treinos
  end 
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "home#index"
end
