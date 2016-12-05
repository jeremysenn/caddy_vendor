Rails.application.routes.draw do
  resources :events
  get 'welcome/index'
  root 'welcome#index'
end
