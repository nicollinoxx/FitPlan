Rails.application.routes.draw do
  get 'fichas_treinos', to: 'fichas_treinos#index'
  get 'fichas_diets', to: 'fichas_diets#index'

  resources :fichas do
    resources :diets
    resources :treinos
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "home#index"
end
