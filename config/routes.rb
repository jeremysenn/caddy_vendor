Rails.application.routes.draw do
  resources :players
  resources :caddies
  resources :members
  resources :clubs
  resources :events
  get 'welcome/index'
  root 'welcome#index'
end
