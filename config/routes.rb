Rails.application.routes.draw do
  get 'welcome/index'

  # resources :vaccine_doses
  resources :patients, only: [:index, :show]

  # xml importation
  post '/xml', to: 'importer#import_file'
  get '/xml', to: 'importer#index'

  # Temp login faking
  get '/login', to: 'welcome#login'
  get '/login/go', to: 'welcome#go'

  # API for importing Patient Data from the Extractor
  post '/data', to: 'importer#import_data'

  # You can have the root of your site routed with "root"
  root 'welcome#index'
end
