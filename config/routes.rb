Rails.application.routes.draw do
  get 'welcome/index'

  resources :vaccine_doses
  resources :patients
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # xml importation
  post '/xml', to: 'xml_importer#import_file'
  get '/xml', to: 'xml_importer#index'

  # Temp login faking
  get '/login', to: 'welcome#login'
  get '/login/go', to: 'welcome#go'
  
  # You can have the root of your site routed with "root"
  root 'welcome#index'
end
