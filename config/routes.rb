Rails.application.routes.draw do
  get 'fichas_treinos', to: 'fichas#show_ficha_treinos'
  get 'fichas_diets', to: 'fichas#show_ficha_diets'

  resources :fichas do
    resources :dietas
    resources :treinos
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "home#index"
end
