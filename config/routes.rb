Rails.application.routes.draw do
  get 'welcome/index'

  resources :immunizations
  resources :patients
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  get '/login', to: 'welcome#login'
  get '/login/go', to: 'welcome#go'
  root 'welcome#index'
end
