Rails.application.routes.draw do
  resources :customers
  resources :transfers
  resources :companies
  devise_for :users
  resources :players do
    member do
      put 'update_tip'
    end
  end
  resources :caddies
  resources :members
  resources :clubs
  resources :events
  get 'welcome/index'
  root 'welcome#index'
end
