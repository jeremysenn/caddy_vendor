Rails.application.routes.draw do
  
  resources :reports
  resources :transactions
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
  resources :caddy_pay_rates
  resources :caddy_rank_descs
  
  resources :caddy_ratings
#  resources :users
  resources :users_admin, :controller => 'users'
  
  get 'welcome/index'
  root 'welcome#index'
end
