Rails.application.routes.draw do
  resources :transfers
  resources :companies
  devise_for :users
  resources :players
  resources :caddies
  resources :members
  resources :clubs
  resources :events
  get 'welcome/index'
  root 'welcome#index'
end
